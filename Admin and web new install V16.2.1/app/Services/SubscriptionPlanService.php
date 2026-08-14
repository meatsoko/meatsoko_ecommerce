<?php

namespace App\Services;

use App\Traits\FileManagerTrait;

class SubscriptionPlanService
{
    use FileManagerTrait;

    public function getAddData(object $request): array
    {
        return [
            'title' => $request['title'],
            'cadence' => $request['cadence'],
            'price' => $request['price'],
            'shipping_cost' => $request['shipping_cost'] ?? 0,
            'image' => $request->hasFile('image') ? $this->upload(dir: 'subscription-plan/', format: 'webp', image: $request->file('image')) : 'def.webp',
            'status' => 'active',
            'created_at' => now(),
            'updated_at' => now(),
        ];
    }

    public function getUpdateData(object $request, object $data): array
    {
        return [
            'title' => $request['title'],
            'cadence' => $request['cadence'],
            'price' => $request['price'],
            'shipping_cost' => $request['shipping_cost'] ?? 0,
            'image' => $request->hasFile('image') ? $this->update('subscription-plan/', $data['image'], 'webp', $request->file('image')) : $data['image'],
            'updated_at' => now(),
        ];
    }
}
