// Shared between both themes' cart-details pages — see resources/themes/*/…/cart-details.blade.php.
// Posts the customer's delivery/self-pickup choice, then reloads so the
// server-computed shipping cost and address requirement reflect it.
function setReceivingMethodFunction() {
    $('.receiving-method-radio').on('change', function () {
        let method = $(this).val();
        $.post({
            url: $('#route-customer-set-receiving-method').data('url'),
            dataType: 'json',
            data: {
                _token: $('meta[name="_token"]').attr('content'),
                method: method
            },
            beforeSend: function () {
                $('#loading').addClass('d-grid');
            },
            success: function () {
                location.reload();
            },
            complete: function () {
                $('#loading').removeClass('d-grid');
            },
        });
    });
}
setReceivingMethodFunction();
