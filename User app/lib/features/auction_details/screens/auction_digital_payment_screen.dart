import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/controllers/participator/auction_participation_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/animated_custom_dialog_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/widgets/order_place_dialog_widget.dart';
import 'package:provider/provider.dart';

class AuctionDigitalPaymentScreen extends StatefulWidget {
  final String url;
  final VoidCallback? onSuccess;

  const AuctionDigitalPaymentScreen({super.key, required this.url, this.onSuccess});

  @override
  State<AuctionDigitalPaymentScreen> createState() =>
      _AuctionDigitalPaymentScreenState();
}

class _AuctionDigitalPaymentScreenState
    extends State<AuctionDigitalPaymentScreen> {
  late final WebViewController _webViewController;
  bool _isLoading = true;
  bool _canRedirect = true;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initWebView();
      _isInitialized = true;
    }
  }

  void _initWebView() {
    _webViewController
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Theme.of(context).cardColor)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress == 100) setState(() => _isLoading = false);
          },
          onPageStarted: _checkRedirect,
          onPageFinished: _checkRedirect,
          onWebResourceError: (e) => debugPrint('WebView error: ${e.description}'),
          onNavigationRequest: (NavigationRequest req) {
            if (_isRedirectUrl(req.url)) {
              _checkRedirect(req.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  bool _isRedirectUrl(String url) {
    return ((url.contains('success') && url.contains('token')) ||
            url.contains('fail') ||
            url.contains('cancel')) &&
        url.contains(AppConstants.baseUrl);
  }

  void _checkRedirect(String url) {
    if (_canRedirect && _isRedirectUrl(url)) {
      _canRedirect = false;
      final bool isSuccess = url.contains('success');
      final bool isFailed = url.contains('fail');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handlePaymentResult(isSuccess: isSuccess, isFailed: isFailed);
      });
    }
  }

  void _handlePaymentResult({required bool isSuccess, required bool isFailed}) {
    if (isSuccess) {
      Provider.of<AuctionParticipationController>(Get.context!, listen: false)
          .resetPaymentState();

      RouterHelper.getDashboardRoute(
        action: RouteAction.pushReplacement,
        page: 'auction_my_bid',
      );

      _showSuccessDialog();
    } else {
      _popToAuctionDetails();

      Future.delayed(const Duration(milliseconds: 400), () {
        showAnimatedDialog(
          Get.context!,
          OrderPlaceDialogWidget(
            icon: Icons.clear,
            title: getTranslated(isFailed ? 'payment_failed' : 'payment_cancelled', Get.context!),
            description: getTranslated(
              isFailed ? 'your_payment_failed' : 'your_payment_cancelled',
              Get.context!,
            ),
            isFailed: true,
          ),
          dismissible: true,
          willFlip: true,
        );
      });
    }
  }

  void _showSuccessDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 700), () {
        if (Get.context == null) return;
        showAnimatedDialog(
          Get.context!,
          OrderPlaceDialogWidget(
            icon: Icons.check,
            title: getTranslated('payment_successful', Get.context!),
            description: getTranslated('payment_successful', Get.context!),
            isFailed: false,
          ),
          dismissible: true,
          willFlip: true,
        );
      });
    });
  }

  void _popToAuctionDetails() {
    if (Navigator.canPop(Get.context!)) {
      Navigator.of(Get.context!).pop();
    }
  }

  Future<void> _onBackPressed() async {
    if (!_canRedirect) return;
    _canRedirect = false;
    _popToAuctionDetails();
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) => _onBackPressed(),
      child: Scaffold(
        backgroundColor: Theme.of(context).cardColor,
        appBar: AppBar(
          title: Text(getTranslated('payment', context) ?? 'Payment'),
          backgroundColor: Theme.of(context).cardColor,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 18),
            onPressed: _onBackPressed,
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  WebViewWidget(controller: _webViewController),
                  if (_isLoading)
                    Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: bottomPadding),
          ],
        ),
      ),
    );
  }
}
