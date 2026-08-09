@php
    use Illuminate\Support\Str;

    $flagReasonLabels = [
        'phone_number' => translate('phone_number_detected'),
        'whatsapp_link' => translate('whatsapp_link_detected'),
        'telegram_link' => translate('telegram_link_detected'),
        'call_me_phrasing' => translate('contact_request_phrasing_detected'),
    ];
@endphp
@extends('layouts.admin.app')

@section('title', translate('flagged_Messages'))

@section('content')
    <div class="content container-fluid">
        <div class="mb-3">
            <h2 class="h1 mb-0 text-capitalize d-flex align-items-center gap-2">
                <img src="{{asset('public/assets/back-end/img/support-ticket.png')}}" alt="">
                {{translate('flagged_Messages')}}
            </h2>
            <p class="text-muted mb-0">{{translate('messages_the_system_flagged_as_a_possible_attempt_to_move_a_deal_off_platform_review_and_take_action_below')}}</p>
        </div>

        <div class="row">
            <div class="col-12">
                <div class="card">
                    <div class="card-body d-flex flex-column gap-20">
                        <div class="d-flex justify-content-between align-items-center gap-20 flex-wrap">
                            <h3 class="mb-0">
                                {{ translate('flagged_conversations')}}
                                <span class="badge text-dark bg-body-secondary fw-semibold rounded-50">{{ $flaggedMessages->total() }}</span>
                            </h3>
                        </div>

                        <div class="table-responsive">
                            <table class="table table-hover table-borderless align-middle">
                                <thead class="text-capitalize">
                                    <tr>
                                        <th>{{translate('date')}}</th>
                                        <th>{{translate('sent_by')}}</th>
                                        <th>{{translate('conversation')}}</th>
                                        <th>{{translate('message')}}</th>
                                        <th>{{translate('reason')}}</th>
                                    </tr>
                                </thead>
                                <tbody>
                                @foreach($flaggedMessages as $chat)
                                    @php
                                        $senderLabel = $chat->sent_by_customer ? translate('customer')
                                            : ($chat->sent_by_seller ? translate('vendor')
                                            : ($chat->sent_by_delivery_man ? translate('delivery_Man')
                                            : ($chat->sent_by_admin ? translate('admin') : translate('n/a'))));

                                        $customerName = $chat->customer ? trim($chat->customer->f_name.' '.$chat->customer->l_name) : null;
                                        $sellerName = $chat->sellerInfo?->shop?->name ?? ($chat->sellerInfo ? trim($chat->sellerInfo->f_name.' '.$chat->sellerInfo->l_name) : null);
                                        $deliveryManName = $chat->deliveryMan ? trim($chat->deliveryMan->f_name.' '.$chat->deliveryMan->l_name) : null;

                                        $parties = array_filter([
                                            $customerName ? translate('customer').': '.$customerName : null,
                                            $sellerName ? translate('vendor').': '.$sellerName : null,
                                            $deliveryManName ? translate('delivery_Man').': '.$deliveryManName : null,
                                            !$chat->seller_id && !$chat->delivery_man_id && !is_null($chat->admin_id) ? translate('admin') : null,
                                        ]);
                                    @endphp
                                    <tr>
                                        <td class="text-nowrap">{{ $chat->created_at?->format('d M Y, h:i A') }}</td>
                                        <td><span class="badge bg-soft-secondary text-dark">{{ $senderLabel }}</span></td>
                                        <td>{{ implode(' ↔ ', $parties) ?: translate('n/a') }}</td>
                                        <td class="overflow-wrap-anywhere" style="max-width: 320px;">{{ Str::limit($chat->message, 120) ?: translate('shared_files') }}</td>
                                        <td>
                                            <span class="badge bg-soft-danger text-danger">
                                                {{ $flagReasonLabels[$chat->flag_reason] ?? $chat->flag_reason }}
                                            </span>
                                        </td>
                                    </tr>
                                @endforeach
                                </tbody>
                            </table>
                            <table class="mt-4">
                                <tfoot>
                                {!! $flaggedMessages->links() !!}
                                </tfoot>
                            </table>
                        </div>
                        @if(count($flaggedMessages) <= 0)
                            @include('layouts.admin.partials._empty-state',['text'=>'no_data_found'],['image'=>'default'])
                        @endif
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection
