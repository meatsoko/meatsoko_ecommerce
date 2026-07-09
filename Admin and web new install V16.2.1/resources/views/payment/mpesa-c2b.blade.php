@extends('payment.layouts.master')

@section('content')
    <div class="mpesa-container">
        <h2>M-Pesa</h2>
        <p>{{ translate('Pay via M-Pesa Paybill / Till using the details below') }}:</p>

        <div class="mpesa-instructions">
            <div class="mpesa-row">
                <span>{{ translate('Business/Paybill Number') }}</span>
                <strong>{{ $shortcode }}</strong>
            </div>
            <div class="mpesa-row">
                <span>{{ translate('Account Number') }}</span>
                <strong>{{ $accountReference }}</strong>
            </div>
            <div class="mpesa-row">
                <span>{{ translate('Amount') }}</span>
                <strong>{{ $data->payment_amount }} {{ $data->currency_code }}</strong>
            </div>
        </div>

        <div class="mpesa-spinner"></div>
        <p>{{ translate('Waiting for your payment confirmation...') }}</p>
        <button type="button" id="mpesa-check-now-button">{{ translate('I have paid') }}</button>
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

        .mpesa-instructions {
            border: 1px solid #ddd;
            border-radius: 8px;
            padding: 1rem 1.5rem;
            min-width: 280px;
        }

        .mpesa-row {
            display: flex;
            justify-content: space-between;
            gap: 1rem;
            padding: 0.35rem 0;
        }

        #mpesa-check-now-button {
            background-color: rgba(69, 160, 73, 0.9);
            color: white;
            border: none;
            padding: 0.5rem 2.5rem;
            font-size: 0.85rem;
            cursor: pointer;
            border-radius: 5px;
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
            const checkNowButton = document.getElementById('mpesa-check-now-button');
            const pollIntervalMs = 4000;

            function checkStatus() {
                fetch("{{ route('mpesa-c2b.status') }}?payment_id=" + paymentId)
                    .then(response => response.json())
                    .then(result => {
                        if (result.status === 1 && result.redirect_url) {
                            clearInterval(pollTimer);
                            window.location.href = result.redirect_url;
                        }
                    });
            }

            const pollTimer = setInterval(checkStatus, pollIntervalMs);
            checkNowButton.addEventListener('click', checkStatus);
        });
    </script>
@endpush
