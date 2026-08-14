<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class SubscriptionPlanAddRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'title' => 'required|string|max:255',
            'cadence' => 'required|in:weekly,monthly',
            'price' => 'required|numeric|min:0.01',
            'shipping_cost' => 'nullable|numeric|min:0',
            'image' => 'nullable|image|mimes:jpg,jpeg,png,gif,bmp,tif,tiff|max:' . getFileUploadMaxSize(unit: 'kb'),
        ];
    }

    public function messages(): array
    {
        return [
            'title.required' => translate('The_title_field_is_required'),
            'cadence.required' => translate('please_select_a_cadence'),
            'price.required' => translate('The_price_field_is_required'),
            'price.min' => translate('the_price_must_be_greater_than_0'),
        ];
    }
}
