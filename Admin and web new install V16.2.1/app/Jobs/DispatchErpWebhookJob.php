<?php

namespace App\Jobs;

use App\Models\ErpApiToken;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use RuntimeException;
use Throwable;

class DispatchErpWebhookJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;


    public int $tries = 5;

    public int $maxExceptions = 5;

    public int $timeout = 120;

    public string $dispatchId;

    public function __construct(
        protected string $event,
        protected array $payload,
    ) {
        $this->dispatchId = (string) Str::uuid();
    }

    public function retryUntil(): \DateTime
    {
        return now()->addHours(6);
    }

    /** Growing backoff (seconds) between retries to ride out longer outages. */
    public function backoff(): array
    {
        return [60, 300, 900, 1800, 3600];
    }

    public function handle(): void
    {
        $rawBody = json_encode(
            ['event' => $this->event, 'data' => $this->payload],
            JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE
        );

        $transientFailures = [];

        foreach (ErpApiToken::withWebhook()->get() as $token) {
            // A retry re-runs this whole loop from a fresh deserialize of the job, so a
            // subscriber that already got this event (success or a definitive 4xx) is
            // remembered here — otherwise a transient failure on one subscriber would
            // cause every OTHER subscriber to receive the same event twice.
            $resolvedKey = "erp-webhook-resolved:{$this->dispatchId}:{$token->id}";

            if (Cache::has($resolvedKey)) {
                continue;
            }

            $secret = $token->decryptedSecret();
            if (!$secret) {
                Log::warning('ERP webhook skipped: secret not recoverable', [
                    'token_id' => $token->id,
                    'event' => $this->event,
                ]);
                Cache::put($resolvedKey, true, now()->addHours(7));
                continue;
            }

            try {
                $hmacKey = hash('sha256', $secret);

                $response = Http::connectTimeout(5)
                    ->timeout(15)
                    ->withHeaders([
                        'X-Webhook-Key' => $token->api_key,
                        'X-Webhook-Signature' => 'sha256=' . hash_hmac('sha256', $rawBody, $hmacKey),
                        'X-Webhook-Event' => $this->event,
                    ])
                    ->withBody($rawBody, 'application/json')
                    ->post($token->webhook_url);

                if ($response->clientError()) {
                    Log::warning('ERP webhook rejected by subscriber', [
                        'token_id' => $token->id,
                        'event' => $this->event,
                        'status' => $response->status(),
                    ]);
                    Cache::put($resolvedKey, true, now()->addHours(7));
                    continue;
                }

                $response->throw();
                $token->forceFill(['webhook_last_dispatched_at' => now()])->saveQuietly();
                Cache::put($resolvedKey, true, now()->addHours(7));
            } catch (Throwable $exception) {
                // Connection error / timeout / 5xx: retryable for this subscriber.
                $transientFailures[] = $token->id;
                Log::warning('ERP webhook transient failure', [
                    'token_id' => $token->id,
                    'event' => $this->event,
                    'message' => $exception->getMessage(),
                ]);
            }
        }
        if (!empty($transientFailures)) {
            throw new RuntimeException(
                'ERP webhook had ' . count($transientFailures) . ' transient failure(s): [' . implode(',', $transientFailures) . ']'
            );
        }
    }

    public function failed(Throwable $exception): void
    {
        Log::error('ERP webhook permanently failed after retries', [
            'event' => $this->event,
            'message' => $exception->getMessage(),
        ]);
    }
}
