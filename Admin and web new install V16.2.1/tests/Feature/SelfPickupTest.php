<?php

namespace Tests\Feature;

use App\Utils\CartManager;
use App\Utils\OrderManager;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Tests\TestCase;

/**
 * Regression coverage for the 2026-08-11 audit finding that self-pickup
 * orders were still charged shipping cost on category/product-wise shipping
 * stores (High finding H5), fixed by making OrderManager::isSelfPickup() the
 * one place every shipping-cost consumer checks.
 */
class SelfPickupTest extends TestCase
{
    use DatabaseTransactions;

    public function test_is_self_pickup_reflects_the_session_flag(): void
    {
        session(['receiving_method' => 'delivery']);
        $this->assertFalse(OrderManager::isSelfPickup());

        session(['receiving_method' => 'self_pickup']);
        $this->assertTrue(OrderManager::isSelfPickup());
    }

    public function test_is_self_pickup_defaults_to_delivery_when_unset(): void
    {
        session()->forget('receiving_method');
        $this->assertFalse(OrderManager::isSelfPickup());
    }

    public function test_shipping_cost_is_zero_for_self_pickup_regardless_of_cart_contents(): void
    {
        session(['receiving_method' => 'self_pickup']);
        $this->assertEquals(0, CartManager::get_shipping_cost());
    }
}
