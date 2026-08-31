<?php

namespace Modules\Courier\CourierProviders;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Modules\Courier\CourierProviders\Contracts\CancelsOrders;
use Modules\Courier\CourierProviders\Contracts\CreatesOrders;
use Modules\Courier\CourierProviders\Contracts\EstimatesDeliveryCharge;
use Modules\Courier\CourierProviders\Contracts\HandlesWebhooks;
use Modules\Courier\CourierProviders\Contracts\ProvidesOrderInfo;
use Modules\Courier\CourierProviders\Contracts\TracksOrders;
use Modules\Courier\app\DataTransferObjects\Requests\OrderData;
use Modules\Courier\app\DataTransferObjects\Requests\QuoteData;
use Modules\Courier\app\DataTransferObjects\Requests\RecipientData;
use Modules\Courier\app\DataTransferObjects\Responses\QuoteResult;
use Modules\Courier\app\DataTransferObjects\Responses\ShipmentResult;
use Modules\Courier\app\DataTransferObjects\Responses\TrackingEvent;
use Modules\Courier\app\DataTransferObjects\Responses\WebhookEvent;
use Modules\Courier\app\Enums\ShipmentStatus;

class UberProvider extends CourierProvider implements
    CreatesOrders,
    ProvidesOrderInfo,
    TracksOrders,
    CancelsOrders,
    EstimatesDeliveryCharge,
    HandlesWebhooks
{
    private const AUTH_URL = 'https://auth.uber.com/oauth/v2/token';

    public function getName(): string
    {
        return 'uber';
    }

    protected function displayName(): string
    {
        return 'Uber Direct';
    }

    public function supportedCountries(): array
    {
        return ['US', 'CA', 'GB', 'AU', 'MX'];
    }

    public function addressMode(): string
    {
        return 'postal';
    }

    // Uber Direct has no separate sandbox host — a "Test" customer_id and its own
    // client credentials, issued from the same Direct Dashboard, simulate delivery
    // outcomes against this one production host instead.
    public function baseUrls(): array
    {
        return [
            self::ENVIRONMENT_SANDBOX => 'https://api.uber.com',
            self::ENVIRONMENT_LIVE    => 'https://api.uber.com',
        ];
    }

    public function credentialFields(): array
    {
        return [
            ['key' => 'client_id', 'label' => 'Client ID', 'type' => 'text', 'required' => true, 'placeholder' => 'Ex: 9fK2mQ7rT4wZ1xC8vB5n', 'help' => 'From the Direct Dashboard, under Developer > API Access.'],
            ['key' => 'client_secret', 'label' => 'Client Secret', 'type' => 'password', 'required' => true, 'help' => 'Issued alongside the Client ID.'],
            ['key' => 'customer_id', 'label' => 'Direct Customer ID', 'type' => 'text', 'required' => true, 'placeholder' => 'Ex: b9c3f2e1-4a6d-4e2b-9c1a-7f8e5d3c2b1a', 'help' => 'Every delivery is created under this ID. Use your Test customer for sandbox, your Live customer for production.'],
            ['key' => 'default_pickup_name', 'label' => 'Pickup Location Name', 'type' => 'text', 'required' => true, 'placeholder' => 'Ex: Meatsoko Warehouse'],
            ['key' => 'default_pickup_phone', 'label' => 'Pickup Contact Phone', 'type' => 'text', 'required' => true, 'placeholder' => 'Ex: +254712345678'],
            ['key' => 'default_pickup_address', 'label' => 'Pickup Address', 'type' => 'text', 'required' => true, 'placeholder' => 'Ex: 12 Riverside Drive, Nairobi, 00100, KE', 'help' => 'Every order is collected from this address — Uber Direct has no per-order pickup selector.'],
            ['key' => 'webhook_signing_key', 'label' => 'Webhook Signing Key', 'type' => 'password', 'required' => false, 'help' => 'From the Direct Dashboard\'s Webhooks tab. Needed to trust inbound delivery-status updates.'],
        ];
    }

    protected function defaultHeaders(): array
    {
        return ['Authorization' => 'Bearer '.$this->token()];
    }

    public function createOrder(OrderData $data): ShipmentResult
    {
        $customerId = (string) ($this->credentials['customer_id'] ?? '');

        $payload = array_filter([
            'pickup_name'          => $this->credentials['default_pickup_name'] ?? null,
            'pickup_phone_number'  => $this->credentials['default_pickup_phone'] ?? null,
            'pickup_address'       => $this->credentials['default_pickup_address'] ?? null,
            'dropoff_name'         => $data->recipient->name,
            'dropoff_phone_number' => $data->recipient->phone,
            'dropoff_address'      => $this->formatAddress($data->recipient),
            'manifest_reference'   => $data->hostOrderReference,
            'external_id'          => $data->hostOrderReference,
            'dropoff_notes'        => $data->note,
            'manifest_items'       => [[
                'name'     => $data->itemDescription ?: 'Parcel',
                'quantity' => $data->quantity ?? 1,
                'size'     => 'medium',
            ]],
        ], static fn ($v) => $v !== null && $v !== '');

        $response = $this->http()->post("/v1/customers/{$customerId}/deliveries", $payload);

        if ($response->failed()) {
            $this->failFromResponse($response);
        }

        $delivery = (array) $response->json();

        return new ShipmentResult(
            consignmentId: (string) ($delivery['id'] ?? ''),
            status: $this->mapStatus((string) ($delivery['status'] ?? 'pending')),
            hostOrderReference: $data->hostOrderReference,
            deliveryFee: isset($delivery['fee']) ? ((float) $delivery['fee']) / 100 : null,
            raw: $delivery,
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
        $customerId = (string) ($this->credentials['customer_id'] ?? '');

        $response = $this->http()->get("/v1/customers/{$customerId}/deliveries/{$consignmentId}");

        if ($response->failed()) {
            $this->failFromResponse($response);
        }

        $delivery = (array) $response->json();

        return new ShipmentResult(
            consignmentId: $consignmentId,
            status: $this->mapStatus((string) ($delivery['status'] ?? 'unknown')),
            hostOrderReference: $delivery['external_id'] ?? null,
            deliveryFee: isset($delivery['fee']) ? ((float) $delivery['fee']) / 100 : null,
            raw: $delivery,
        );
    }

    public function trackOrder(string $consignmentId): array
    {
        $result = $this->orderInfo($consignmentId);

        return [new TrackingEvent(
            status: $result->status,
            occurredAt: (string) ($result->raw['updated'] ?? now()->toIso8601String()),
            description: $result->raw['courier']['name'] ?? null,
            raw: $result->raw,
        )];
    }

    public function cancelOrder(string $consignmentId): ShipmentResult
    {
        $customerId = (string) ($this->credentials['customer_id'] ?? '');

        $response = $this->http()->post("/v1/customers/{$customerId}/deliveries/{$consignmentId}/cancel");

        if ($response->failed()) {
            $this->failFromResponse($response);
        }

        return new ShipmentResult(
            consignmentId: $consignmentId,
            status: ShipmentStatus::Cancelled,
            raw: (array) $response->json(),
        );
    }

    public function getDeliveryCharges(QuoteData $data): QuoteResult
    {
        $customerId = (string) ($this->credentials['customer_id'] ?? '');

        $payload = array_filter([
            'pickup_address'    => $this->credentials['default_pickup_address'] ?? null,
            'dropoff_address'   => $this->formatQuoteAddress($data),
            'pickup_latitude'   => $data->fromLatitude,
            'pickup_longitude'  => $data->fromLongitude,
            'dropoff_latitude'  => $data->toLatitude,
            'dropoff_longitude' => $data->toLongitude,
        ], static fn ($v) => $v !== null && $v !== '');

        $response = $this->http()->post("/v1/customers/{$customerId}/delivery_quotes", $payload);

        if ($response->failed()) {
            $this->failFromResponse($response);
        }

        $quote = (array) $response->json();

        return new QuoteResult(
            totalCost: isset($quote['fee']) ? ((float) $quote['fee']) / 100 : 0.0,
            currency: (string) ($quote['currency'] ?? ''),
            raw: $quote,
        );
    }

    public function verifyWebhook(Request $request): bool
    {
        $key = $this->credentials['webhook_signing_key'] ?? null;

        if ($key === null || $key === '') {
            return false;
        }

        $signature = hash_hmac('sha256', $request->getContent(), $key);

        return hash_equals($signature, (string) $request->header('X-Uber-Signature'));
    }

    public function parseWebhook(Request $request): WebhookEvent
    {
        $delivery = (array) ($request->input('data') ?? $request->all());

        return new WebhookEvent(
            consignmentId: (string) ($delivery['id'] ?? $request->input('delivery_id', '')),
            status: $this->mapStatus((string) ($delivery['status'] ?? $request->input('status', 'unknown'))),
            hostOrderReference: $delivery['external_id'] ?? null,
            occurredAt: $request->input('created_at'),
            raw: $request->all(),
        );
    }

    private function formatAddress(RecipientData $recipient): string
    {
        return implode(', ', array_filter([
            $recipient->address,
            $recipient->cityName,
            $recipient->stateProvince,
            $recipient->postalCode,
            $recipient->countryCode,
        ], static fn (?string $part): bool => filled($part)));
    }

    private function formatQuoteAddress(QuoteData $data): string
    {
        return implode(', ', array_filter([
            $data->toCityName,
            $data->toPostalCode,
            $data->toCountryCode,
        ], static fn (?string $part): bool => filled($part)));
    }

    protected function token(): string
    {
        $key = 'courier.uber.token.'.md5(($this->credentials['client_id'] ?? '').'|'.$this->environment());

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
                'scope'         => 'eats.deliveries',
            ]);

        if ($response->failed()) {
            $this->failFromResponse($response);
        }

        $token = (string) $response->json('access_token');
        $ttl = max(60, (int) $response->json('expires_in', 2592000) - 60);
        Cache::put($key, $token, $ttl);

        return $token;
    }

    protected function mapStatus(string $raw): ShipmentStatus
    {
        return match (strtolower(trim($raw))) {
            'pending'                         => ShipmentStatus::Pending,
            'pickup'                          => ShipmentStatus::PickupRequested,
            'pickup_complete'                 => ShipmentStatus::PickedUp,
            'dropoff', 'en_route_to_dropoff'  => ShipmentStatus::OutForDelivery,
            'delivered'                       => ShipmentStatus::Delivered,
            'canceled', 'cancelled'           => ShipmentStatus::Cancelled,
            'returned'                        => ShipmentStatus::Returned,
            default                           => ShipmentStatus::Unknown,
        };
    }
}
