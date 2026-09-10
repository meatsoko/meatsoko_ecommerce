import 'package:flutter/material.dart';
import 'package:user_app/common/basewidget/custom_app_bar_widget.dart';
import 'package:user_app/localization/language_constrants.dart';
import 'package:user_app/utill/dimensions.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:url_launcher/url_launcher.dart';

/// Copied verbatim from https://shop.meatsokogroup.com/business-page/privacy-policy
/// on 2026-09-09. Bundled directly in the app (rather than fetched live from
/// the backend's business-pages API, the way the generic HTML-view screen
/// does) so this page is always reachable even if that content is ever
/// missing/misconfigured server-side.
const String _privacyPolicyHtml = '''<p>Meatsoko Ecosystem Limited ("we," "our," or "us") is dedicated to protecting the privacy and personal data of our customers, partners, and platform users. This Privacy Policy details how we collect, store, share, and protect your information when you visit meatsoko.co.ke, download the Meatsoko mobile application, or interact with our fulfillment services, including Kiamaiko Meats HQ.</p><p><br></p><p><br></p><p>1. Information We Collect</p><p>To process your fresh food orders and provide premium logistics services, we collect the following types of personal information:</p><ol><li data-list="bullet"><span class="ql-ui" contenteditable="false"></span><strong>Account Information:</strong> Your name, email address, physical delivery address, and telephone number provided when creating an account.</li><li data-list="bullet"><span class="ql-ui" contenteditable="false"></span><strong>Transaction Details:</strong> Order histories, specific meat cuts purchased, total spending, and timestamps of your purchases.</li><li data-list="bullet"><span class="ql-ui" contenteditable="false"></span><strong>Payment Records:</strong> Transaction reference codes and billing details. <em>Note: We do not directly store your raw credit card numbers or M-Pesa PIN numbers; these are handled securely by licensed third-party payment gateways.</em></li><li data-list="bullet"><span class="ql-ui" contenteditable="false"></span><strong>Location Data:</strong> Precise geographical location details from your mobile device (if permitted) to optimize delivery routing and assign your order to the nearest fulfillment hub.</li></ol><p><br></p><p>2. How We Use Your Information</p><p>We utilize your data to run efficient, secure operations, specifically to:</p><ol><li data-list="bullet"><span class="ql-ui" contenteditable="false"></span>Complete order transactions, package your items, and fulfill doorstep deliveries.</li><li data-list="bullet"><span class="ql-ui" contenteditable="false"></span>Coordinate real-time location routing with our cold-chain delivery couriers.</li><li data-list="bullet"><span class="ql-ui" contenteditable="false"></span>Process secure payments and handle system-approved refunds or credit notes.</li><li data-list="bullet"><span class="ql-ui" contenteditable="false"></span>Send transaction updates, M-Pesa receipts, and customer service alerts.</li><li data-list="bullet"><span class="ql-ui" contenteditable="false"></span>Detect, prevent, and mitigate fraudulent account access or suspicious payment actions.</li><li data-list="bullet"><span class="ql-ui" contenteditable="false"></span>Comply with regulatory requirements established by the Kenya Revenue Authority (KRA) and health inspectors.</li></ol><p><br></p><p>3. Data Sharing and Third Parties</p><p>We do not sell your personal data. We only share specific data slices with trusted partners essential to running the ecosystem:</p><ol><li data-list="bullet"><span class="ql-ui" contenteditable="false"></span><strong>Logistics &amp; Couriers:</strong> Sharing your address, phone number, and name with dispatch drivers so they can find your location.</li><li data-list="bullet"><span class="ql-ui" contenteditable="false"></span><strong>Payment Gateways:</strong> Sending transactional value tokens to integrated mobile money providers (like Safaricom M-Pesa) and banking gateways to clear invoices.</li><li data-list="bullet"><span class="ql-ui" contenteditable="false"></span><strong>Regulatory Authorities:</strong> Disclosing data if required by law, court order, or formal veterinary public health audits.</li></ol><p><br></p><p>4. Data Security and Retention</p><ol><li data-list="bullet"><span class="ql-ui" contenteditable="false"></span><strong>Protection Systems:</strong> We utilize industry-standard Transport Layer Security (TLS/SSL) encryption protocols to secure data transitions across our network.</li><li data-list="bullet"><span class="ql-ui" contenteditable="false"></span><strong>Storage Limits:</strong> We store your records only as long as necessary to manage your account history, fulfill local accounting/tax cycles, or resolve ongoing consumer disputes. Unused or deactivated account data is securely purged after its statutory retention window closes.</li></ol><p><br></p><p>5. Your Rights Under the Kenyan Data Protection Act</p><p>In accordance with local data privacy regulations, you retain specific operational rights over your information:</p><ol><li data-list="bullet"><span class="ql-ui" contenteditable="false"></span><strong>Access &amp; Portability:</strong> The right to request copies of the personal data we hold about you.</li><li data-list="bullet"><span class="ql-ui" contenteditable="false"></span><strong>Correction:</strong> The right to modify incorrect, outdated, or incomplete registration profile details.</li><li data-list="bullet"><span class="ql-ui" contenteditable="false"></span><strong>Erasure:</strong> The right to request the permanent deletion of your account and personal history (subject to overriding legal tax/billing preservation constraints).</li><li data-list="bullet"><span class="ql-ui" contenteditable="false"></span><strong>Objection:</strong> The right to opt out of marketing subscription emails and promotional SMS blasts at any time.</li></ol><p><br></p><p>6. Updates to This Policy</p><p>We review and modify this privacy policy regularly to keep pace with operational changes and new legal data directives. Any revisions become active the moment they are updated online. Your continued interaction with Meatsoko indicates your formal acknowledgement of our updated privacy practices.</p>''';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      body: Column(children: [
        CustomAppBar(title: getTranslated('privacy_policy', context) ?? 'Privacy Policy'),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Dimensions.homePagePadding),
            physics: const BouncingScrollPhysics(),
            child: HtmlWidget(
              _privacyPolicyHtml,
              onTapUrl: (String url) =>
                  launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
              textStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
          ),
        ),
      ]),
    );
  }
}
