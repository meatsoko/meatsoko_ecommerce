<?php

namespace Modules\Courier\CourierProviders;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Modules\Courier\CourierProviders\Contracts\CancelsOrders;
use Modules\Courier\CourierProviders\Contracts\CreatesOrders;
use Modules\Courier\CourierProviders\Contracts\HandlesWebhooks;
use Modules\Courier\CourierProviders\Contracts\ProvidesOrderInfo;
use Modules\Courier\CourierProviders\Contracts\TracksOrders;
use Modules\Courier\app\DataTransferObjects\Requests\OrderData;
use Modules\Courier\app\DataTransferObjects\Responses\ShipmentResult;
use Modules\Courier\app\DataTransferObjects\Responses\TrackingEvent;
use Modules\Courier\app\DataTransferObjects\Responses\WebhookEvent;
use Modules\Courier\app\Enums\ShipmentStatus;

class BoltProvider extends CourierProvider implements
    CreatesOrders,
    ProvidesOrderInfo,
    TracksOrders,
    CancelsOrders,
    HandlesWebhooks
{
    private const AUTH_URL = 'https://oidc.bolt.eu/token';

    public function getName(): string
    {
        return 'bolt';
    }

    protected function displayName(): string
    {
        return 'Bolt Food';
    }

    public function supportedCountries(): array
    {
        return ['KE', 'NG', 'GH', 'ZA', 'CI', 'EE', 'LV', 'LT', 'PL', 'RO'];
    }

    public function addressMode(): string
    {
        return 'postal';
    }

    public function baseUrls(): array
    {
        return [
            self::ENVIRONMENT_SANDBOX => 'https://node.bolt.eu/sandbox-partner-api',
            self::ENVIRONMENT_LIVE    => 'https://node.bolt.eu/partner-api',
        ];
    }

    public function credentialFields(): array
    {
        return [
            ['key' => 'integrator_id', 'label' => 'Integrator ID', 'type' => 'text', 'required' => true, 'help' => 'Issued by Bolt when your partner integration was approved.'],
            ['key' => 'client_id', 'label' => 'Client ID', 'type' => 'text', 'required' => true, 'help' => 'Issued alongside the Integrator ID for OAuth access.'],
            ['key' => 'client_secret', 'label' => 'Client Secret', 'type' => 'password', 'required' => true],
            ['key' => 'store_id', 'label' => 'Bolt Store ID', 'type' => 'text', 'required' => true, 'placeholder' => 'Ex: 4471203', 'help' => 'The store this account books deliveries for. Pickup address is whatever Bolt has on file for it — there is no per-order pickup selector.'],
            ['key' => 'webhook_secret', 'label' => 'Webhook HMAC Secret', 'type' => 'password', 'required' => false, 'help' => 'Issued alongside the Integrator ID. Needed to trust inbound order/courier status updates.'],
        ];
    }

    protected function defaultHeaders(): array
    {
        return [
            'Authorization' => 'Bearer '.$this->token(),
            'X-Integrator-Id' => (string) ($this->credentials['integrator_id'] ?? ''),
        ];
    }

    public function createOrder(OrderData $data): ShipmentResult
    {
        $storeId = (string) ($this->credentials['store_id'] ?? '');

        $payload = array_filter([
            'store_id'          => $storeId,
            'reference_id'      => $data->hostOrderReference,
            'customer_name'     => $data->recipient->name,
            'customer_phone'    => $data->recipient->phone,
            'delivery_address'  => $this->formatAddress($data),
            'delivery_note'     => $data->note,
            'items'             => [[
                'name'     => $data->itemDescription ?: 'Parcel',
                'quantity' => $data->quantity ?? 1,
            ]],
        ], static fn ($v) => $v !== null && $v !== '');

        $response = $this->http()->post('/v1/deliveries', $payload);

        if ($response->failed()) {
            $this->failFromResponse($response);
        }

        $order = (array) $response->json('data', $response->json() ?? []);

        return new ShipmentResult(
            consignmentId: (string) ($order['order_id'] ?? ''),
            status: $this->mapStatus((string) ($order['status'] ?? 'pending')),
            hostOrderReference: $order['reference_id'] ?? $data->hostOrderReference,
            trackingCode: $order['tracking_url'] ?? null,
            raw: $order,
        );
    }

    public function getOrderDetails(string $consignmentId): ShipmentResult
    {
        return $this->orderInfo($consignmentId);
    }

    public function getOrderShortInfo(string $consignmentId): ShipmentResult
    {
        return $this->orderInfo($consignmentId);
    }

    public function getOrderStatus(string $consignmentId): ShipmentResult
    {
        return $this->orderInfo($consignmentId);
    }

    private function orderInfo(string $consignmentId): ShipmentResult
    {
        $response = $this->http()->get("/v1/deliveries/{$consignmentId}");

        if ($response->failed()) {
            $this->failFromResponse($response);
        }

        $order = (array) $response->json('data', $response->json() ?? []);

        return new ShipmentResult(
            consignmentId: $consignmentId,
            status: $this->mapStatus((string) ($order['status'] ?? 'unknown')),
            hostOrderReference: $order['reference_id'] ?? null,
            raw: $order,
        );
    }

    public function trackOrder(string $consignmentId): array
    {
        $response = $this->http()->get("/v1/deliveries/{$consignmentId}/events");

        if ($response->failed()) {
            $this->failFromResponse($response);
        }

        $rows = (array) $response->json('data', $response->json('events', []));

        if ($rows === []) {
            $result = $this->orderInfo($consignmentId);

            return [new TrackingEvent(
                status: $result->status,
                occurredAt: now()->toIso8601String(),
                raw: $result->raw,
            )];
        }

        return array_map(static fn (array $row) => new TrackingEvent(
            status: ShipmentStatus::tryFrom((string) ($row['status'] ?? '')) ?? ShipmentStatus::Unknown,
            occurredAt: (string) ($row['occurred_at'] ?? $row['timestamp'] ?? ''),
            description: $row['description'] ?? null,
            raw: $row,
        ), $rows);
    }

    public function cancelOrder(string $consignmentId): ShipmentResult
    {
        $response = $this->http()->post("/v1/deliveries/{$consignmentId}/cancel");

        if ($response->failed()) {
            $this->failFromResponse($response);
        }

        return new ShipmentResult(
            consignmentId: $consignmentId,
            status: ShipmentStatus::Cancelled,
            raw: (array) $response->json(),
        );
    }

    public function verifyWebhook(Request $request): bool
    {
        $secret = $this->credentials['webhook_secret'] ?? null;

        if ($secret === null || $secret === '') {
            return false;
        }

        $signature = hash_hmac('sha256', $request->getContent(), $secret);

        return hash_equals($signature, (string) $request->header('X-Bolt-Signature'));
    }

    public function parseWebhook(Request $request): WebhookEvent
    {
        return new WebhookEvent(
            consignmentId: (string) $request->input('order_id', ''),
            status: $this->mapStatus((string) $request->input('status', 'unknown')),
            hostOrderReference: $request->input('reference_id'),
            occurredAt: $request->input('occurred_at') ?? $request->input('timestamp'),
            raw: $request->all(),
        );
    }

    private function formatAddress(OrderData $data): string
    {
        $recipient = $data->recipient;

        return implode(', ', array_filter([
            $recipient->address,
            $recipient->cityName,
            $recipient->stateProvince,
            $recipient->postalCode,
            $recipient->countryCode,
        ], static fn (?string $part): bool => filled($part)));
    }

    protected function token(): string
    {
        $key = 'courier.bolt.token.'.md5(($this->credentials['client_id'] ?? '').'|'.$this->environment());

        if ($cached = Cache::get($key)) {
            return $cached;
        }

        $response = Http::asForm()
            ->timeout((int) config('courier.http.timeout', 30))
            ->acceptJson()
            ->post(self::AUTH_URL, [
                'client_id'     => $this->credentials['client_id'] ?? '',
                'client_secret' => $this->credentials['client_secret'] ?? '',
                'grant_type'    => 'client_credentials',
            ]);

        if ($response->failed()) {
            $this->failFromResponse($response);
        }

        $token = (string) $response->json('access_token');
        $ttl = max(60, (int) $response->json('expires_in', 3000) - 60);
        Cache::put($key, $token, $ttl);

        return $token;
    }

    protected function mapStatus(string $raw): ShipmentStatus
    {
        $key = str_replace([' ', '-'], '_', strtolower(trim($raw)));

        return match ($key) {
            'created', 'accepted'          => ShipmentStatus::Pending,
            'courier_assigned'             => ShipmentStatus::PickupRequested,
            'picked_up'                    => ShipmentStatus::PickedUp,
            'en_route', 'in_delivery'      => ShipmentStatus::OutForDelivery,
            'delivered'                    => ShipmentStatus::Delivered,
            'cancelled', 'canceled'        => ShipmentStatus::Cancelled,
            'returned'                     => ShipmentStatus::Returned,
            'failed'                       => ShipmentStatus::Failed,
            default                        => ShipmentStatus::Unknown,
        };
    }
}
