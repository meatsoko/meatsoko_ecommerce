<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

/**
 * @property string $f_name
 * @property string $l_name
 * @property string $phone
 * @property string $email
 * @property string $password
 * @property string $confirm_password
 */
class AffiliateAddRequest extends FormRequest
{
    protected $stopOnFirstFailure = false;

    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'f_name' => 'required|string|max:30',
            'l_name' => 'nullable|string|max:30',
            'phone' => 'nullable|string|max:25',
            'email' => 'required|email|unique:affiliates,email',
            'password' => 'required|min:8|regex:/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*\W)(?!.*\s).{8,}$/|same:confirm_password',
        ];
    }

    public function messages(): array
    {
        return [
            'f_name.required' => translate('The_first_name_field_is_required'),
            'email.required' => translate('The_email_field_is_required'),
            'email.unique' => translate('The_email_has_already_been_taken'),
            'password.required' => translate('The_password_field_is_required'),
            'password.same' => translate('The_password_and_confirm_password_must_match'),
            'password.regex' => translate('The_password_must_be_at_least_8_characters_long_and_contain_at_least_one_uppercase_letter').','.translate('_one_lowercase_letter').','.translate('_one_digit_').','.translate('_one_special_character').','.translate('_and_no_spaces').'.',
            'password.min' => translate('The_password_must_be_at_least :min_characters', ['min' => 8]),
        ];
    }
}
