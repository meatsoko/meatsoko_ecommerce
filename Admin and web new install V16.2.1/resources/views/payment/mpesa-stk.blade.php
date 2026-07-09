@extends('payment.layouts.master')

@section('content')
    <div class="mpesa-container">
        <h2>M-Pesa</h2>

        <div id="mpesa-form-step">
            <p>{{ translate('Amount') }}: <strong>{{ $data->payment_amount }} {{ $data->currency_code }}</strong></p>
            <label for="mpesa-phone">{{ translate('M-Pesa phone number') }}</label>
            <input type="tel" id="mpesa-phone" placeholder="07XXXXXXXX"
                   value="{{ ltrim($payer?->phone ?? '', '+') }}">
            <button type="button" id="mpesa-stk-push-button">{{ translate('Send STK Push') }}</button>
            <p id="mpesa-error" class="mpesa-error" style="display:none;"></p>
        </div>

        <div id="mpesa-waiting-step" style="display:none;">
            <div class="mpesa-spinner"></div>
            <p>{{ translate('Check your phone and enter your M-Pesa PIN to complete payment...') }}</p>
            <button type="button" id="mpesa-resend-button" style="display:none;">{{ translate('Resend STK Push') }}</button>
        </div>
    </div>
@endsection

@push('script')
    <style>
        .mpesa-container {
            display: flex;
            justify-content: center;
            align-items: center;
            flex-direction: column;
            min-height: 100vh;
            gap: 1rem;
            text-align: center;
            padding: 1rem;
        }

        #mpesa-form-step, #mpesa-waiting-step {
            display: flex;
            flex-direction: column;
            gap: 0.75rem;
            align-items: center;
        }

        #mpesa-phone {
            padding: 0.5rem 1rem;
            border: 1px solid #ccc;
            border-radius: 5px;
            font-size: 1rem;
        }

        #mpesa-stk-push-button, #mpesa-resend-button {
            background-color: rgba(69, 160, 73, 0.9);
            color: white;
            border: none;
            padding: 0.5rem 2.5rem;
            font-size: 0.85rem;
            cursor: pointer;
            border-radius: 5px;
        }

        .mpesa-error {
            color: #d9534f;
        }

        .mpesa-spinner {
            width: 40px;
            height: 40px;
            border: 4px solid #ddd;
            border-top-color: rgba(69, 160, 73, 0.9);
            border-radius: 50%;
            animation: mpesa-spin 1s linear infinite;
        }

        @keyframes mpesa-spin {
            to { transform: rotate(360deg); }
        }
    </style>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            const paymentId = "{{ $data->id }}";
            const pushButton = document.getElementById('mpesa-stk-push-button');
            const resendButton = document.getElementById('mpesa-resend-button');
            const errorEl = document.getElementById('mpesa-error');
            const formStep = document.getElementById('mpesa-form-step');
            const waitingStep = document.getElementById('mpesa-waiting-step');
            let pollTimer = null;
            let pollElapsedMs = 0;
            const pollIntervalMs = 3000;
            const resendAfterMs = 90000;

            function sendStkPush() {
                errorEl.style.display = 'none';
                const phone = document.getElementById('mpesa-phone').value.trim();
                if (!phone) {
                    errorEl.textContent = "{{ translate('Please enter your M-Pesa phone number') }}";
                    errorEl.style.display = 'block';
                    return;
                }

                fetch("{{ route('mpesa-stk.push') }}", {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRF-TOKEN': "{{ csrf_token() }}"
                    },
                    body: JSON.stringify({ payment_id: paymentId, phone: phone })
                })
                    .then(response => response.json())
                    .then(result => {
                        if (result.status === 1) {
                            formStep.style.display = 'none';
                            waitingStep.style.display = 'flex';
                            pollElapsedMs = 0;
                            startPolling();
                        } else {
                            errorEl.textContent = result.message || "{{ translate('Unable to initiate M-Pesa payment') }}";
                            errorEl.style.display = 'block';
                        }
                    })
                    .catch(() => {
                        errorEl.textContent = "{{ translate('Something went wrong, please try again') }}";
                        errorEl.style.display = 'block';
                    });
            }

            function startPolling() {
                if (pollTimer) clearInterval(pollTimer);
                pollTimer = setInterval(function () {
                    pollElapsedMs += pollIntervalMs;
                    fetch("{{ route('mpesa-stk.status') }}?payment_id=" + paymentId)
                        .then(response => response.json())
                        .then(result => {
                            if (result.status === 1 && result.redirect_url) {
                                clearInterval(pollTimer);
                                window.location.href = result.redirect_url;
                            } else if (pollElapsedMs >= resendAfterMs) {
                                resendButton.style.display = 'inline-block';
                            }
                        });
                }, pollIntervalMs);
            }

            pushButton.addEventListener('click', sendStkPush);
            resendButton.addEventListener('click', function () {
                resendButton.style.display = 'none';
                waitingStep.style.display = 'none';
                formStep.style.display = 'flex';
            });
        });
    </script>
@endpush
