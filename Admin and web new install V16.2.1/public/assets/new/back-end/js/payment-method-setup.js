$("#payment-method-search").on("keyup keypress change", function () {
    var value = $(this).val().toLowerCase();

    $(".payment-gateway-cards").each(function () {
        $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1);
    });

    let visibleUsers = $(".payment-gateway-cards:visible").length;

    if (visibleUsers > 0) {
        $('.empty-state-for-payment').addClass('d-none').removeClass('d-flex');
    } else {
        $('.empty-state-for-payment').removeClass('d-none');
    }
});

$('#payment-method-offline').on('submit', function(event){
    event.preventDefault();
    $.ajaxSetup({
        headers: {
            'X-CSRF-TOKEN': $('meta[name="_token"]').attr('content')
        }
    });
    $.ajax({
        url: $(this).attr('action'),
        method: $(this).attr('method'),
        data: $(this).serialize(),
        success: function (data) {
            if(parseInt(data.status) === 1) {
                toastMagic.success(data.message);
                location.href = data.redirect_url;
            }else {
                toastMagic.error(data.message);
            }
        }
    });
});

$(document).on('click', '.mpesa-c2b-register-urls-btn', function (event) {
    event.preventDefault();
    let button = $(this);
    let url = button.attr('data-url');

    button.prop('disabled', true);
    $.ajaxSetup({
        headers: {
            'X-CSRF-TOKEN': $('meta[name="_token"]').attr('content')
        }
    });
    $.ajax({
        url: url,
        method: 'POST',
        success: function (data) {
            if (parseInt(data.status) === 1) {
                toastMagic.success(data.message);
            } else {
                toastMagic.error(data.message);
            }
        },
        error: function () {
            toastMagic.error('Something went wrong. Please try again.');
        },
        complete: function () {
            button.prop('disabled', false);
        }
    });
});
