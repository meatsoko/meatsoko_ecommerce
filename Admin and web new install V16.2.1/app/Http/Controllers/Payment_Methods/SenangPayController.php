<?php

namespace App\Http\Controllers\Payment_Methods;

use App\Models\PaymentRequest;
use App\Models\User;
use App\Traits\Processor;
use Illuminate\Contracts\Foundation\Application;
use Illuminate\Contracts\View\Factory;
use Illuminate\Contracts\View\View;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Routing\Controller;
use Illuminate\Routing\Redirector;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class SenangPayController extends Controller
{
    use Processor;

    private $config_values;

    private PaymentRequest $payment;
    private $user;

    public function __construct(PaymentRequest $payment, User $user)
    {
        $config = $this->payment_config('senang_pay', 'payment_config');
        if (!is_null($config) && $config->mode == 'live') {
            $this->config_values = json_decode($config->live_values);
        } elseif (!is_null($config) && $config->mode == 'test') {
            $this->config_values = json_decode($config->test_values);
        }
        $this->payment = $payment;
        $this->user = $user;
    }

    public function index(Request $request): View|Factory|JsonResponse|Application
    {
        $validator = Validator::make($request->all(), [
            'payment_id' => 'required|uuid'
        ]);

        if ($validator->fails()) {
            return response()->json($this->response_formatter(GATEWAYS_DEFAULT_400, null, $this->error_processor($validator)), 400);
        }

        $payment_data = $this->payment::where(['id' => $request['payment_id']])->where(['is_paid' => 0])->first();
        if (!isset($payment_data)) {
            return response()->json($this->response_formatter(GATEWAYS_DEFAULT_204), 200);
        }
        $payer = json_decode($payment_data['payer_information']);
        $config = $this->config_values;
        session()->put('payment_id', $payment_data->id);
        return view('payment.senang-pay', compact('payment_data', 'payer', 'config'));
    }

    public function return_senang_pay(Request $request): JsonResponse|Redirector|RedirectResponse|Application
    {
        $payment_data = $this->payment::where(['id' => session()->get('payment_id')])->where(['is_paid' => 0])->first();
        $secretKey = trim($this->config_values->secret_key ?? '');

        // SenangPay's return URL previously had NO signature check at all — status_id
        // alone was trusted, so simply loading this URL with status_id=1 marked an
        // order paid without ever paying. The hash SenangPay documents for their
        // return callback (secret_key+status_id+order_id+transaction_id+msg) proves
        // the response actually came from SenangPay for this specific order_id.
        $expectedHash = $secretKey !== ''
            ? md5($secretKey . $request['status_id'] . $request['order_id'] . $request['transaction_id'] . $request['msg'])
            : null;

        if ($payment_data
            && $request['status_id'] == 1
            && $expectedHash !== null
            && hash_equals($expectedHash, (string)$request['hash'])
            && (string)$request['order_id'] === (string)$payment_data->attribute_id
            && !$this->payment::where('transaction_id', $request['transaction_id'])->exists()
        ) {
            $updated = false;
            DB::transaction(function () use ($payment_data, $request, &$updated) {
                $locked = $this->payment::where(['id' => $payment_data->id])->lockForUpdate()->first();
                if ($locked && !$locked->is_paid) {
                    $locked->payment_method = 'senang_pay';
                    $locked->is_paid = 1;
                    $locked->transaction_id = $request['transaction_id'];
                    $locked->save();
                    $updated = true;
                }
            });

            if ($updated) {
                $data = $this->payment::where(['id' => $payment_data->id])->first();
                if (isset($data) && function_exists($data->success_hook)) {
                    call_user_func($data->success_hook, $data);
                }
                return $this->payment_response($data, 'success');
            }
        }
        $payment_data = $this->payment::where(['id' => session()->get('payment_id')])->first();
        if (isset($payment_data) && function_exists($payment_data->failure_hook)) {
            call_user_func($payment_data->failure_hook, $payment_data);
        }
        return $this->payment_response($payment_data,'fail');
    }
}
