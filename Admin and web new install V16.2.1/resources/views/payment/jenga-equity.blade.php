@extends('payment.layouts.master')

@section('content')
    <div class="jenga-container">
        <h2>Equity Bank</h2>

        <div id="jenga-form-step">
            <p>{{ translate('Amount') }}: <strong>{{ $data->payment_amount }} {{ $data->currency_code }}</strong></p>
            <label for="jenga-phone">{{ translate('Equitel phone number') }}</label>
            <input type="tel" id="jenga-phone" placeholder="07XXXXXXXX"
                   value="{{ ltrim($payer?->phone ?? '', '+') }}">
            <button type="button" id="jenga-push-button">{{ translate('Send Payment Request') }}</button>
            <p id="jenga-error" class="jenga-error" style="display:none;"></p>
        </div>

        <div id="jenga-waiting-step" style="display:none;">
            <div class="jenga-spinner"></div>
            <p>{{ translate('Check your phone and confirm the payment request to complete payment...') }}</p>
            <button type="button" id="jenga-resend-button" style="display:none;">{{ translate('Resend Payment Request') }}</button>
        </div>
    </div>
@endsection

@push('script')
    <style>
        .jenga-container {
            display: flex;
            justify-content: center;
            align-items: center;
            flex-direction: column;
            min-height: 100vh;
            gap: 1rem;
            text-align: center;
            padding: 1rem;
        }

        #jenga-form-step, #jenga-waiting-step {
            display: flex;
            flex-direction: column;
            gap: 0.75rem;
            align-items: center;
        }

        #jenga-phone {
            padding: 0.5rem 1rem;
            border: 1px solid #ccc;
            border-radius: 5px;
            font-size: 1rem;
        }

        #jenga-push-button, #jenga-resend-button {
            background-color: rgba(148, 26, 42, 0.9);
            color: white;
            border: none;
            padding: 0.5rem 2.5rem;
            font-size: 0.85rem;
            cursor: pointer;
            border-radius: 5px;
        }

        .jenga-error {
            color: #d9534f;
        }

        .jenga-spinner {
            width: 40px;
            height: 40px;
            border: 4px solid #ddd;
            border-top-color: rgba(148, 26, 42, 0.9);
            border-radius: 50%;
            animation: jenga-spin 1s linear infinite;
        }

        @keyframes jenga-spin {
            to { transform: rotate(360deg); }
        }
    </style>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            const paymentId = "{{ $data->id }}";
            const pushButton = document.getElementById('jenga-push-button');
            const resendButton = document.getElementById('jenga-resend-button');
            const errorEl = document.getElementById('jenga-error');
            const formStep = document.getElementById('jenga-form-step');
            const waitingStep = document.getElementById('jenga-waiting-step');
            let pollTimer = null;
            let pollElapsedMs = 0;
            const pollIntervalMs = 3000;
            const resendAfterMs = 90000;

            function sendPush() {
                if (pushButton.disabled) {
                    return;
                }
                errorEl.style.display = 'none';
                const phone = document.getElementById('jenga-phone').value.trim();
                if (!phone) {
                    errorEl.textContent = "{{ translate('Please enter your Equitel phone number') }}";
                    errorEl.style.display = 'block';
                    return;
                }

                pushButton.disabled = true;

                fetch("{{ route('jenga-equity.push') }}", {
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
                            errorEl.textContent = result.message || "{{ translate('Unable to initiate Equity payment') }}";
                            errorEl.style.display = 'block';
                            pushButton.disabled = false;
                        }
                    })
                    .catch(() => {
                        errorEl.textContent = "{{ translate('Something went wrong, please try again') }}";
                        errorEl.style.display = 'block';
                        pushButton.disabled = false;
                    });
            }

            function startPolling() {
                if (pollTimer) clearInterval(pollTimer);
                pollTimer = setInterval(function () {
                    pollElapsedMs += pollIntervalMs;
                    fetch("{{ route('jenga-equity.status') }}?payment_id=" + paymentId)
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

            pushButton.addEventListener('click', sendPush);
            resendButton.addEventListener('click', function () {
                resendButton.style.display = 'none';
                waitingStep.style.display = 'none';
                formStep.style.display = 'flex';
                pushButton.disabled = false;
            });
        });
    </script>
@endpush
