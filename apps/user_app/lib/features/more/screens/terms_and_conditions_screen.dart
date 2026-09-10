import 'package:flutter/material.dart';
import 'package:user_app/common/basewidget/custom_app_bar_widget.dart';
import 'package:user_app/localization/language_constrants.dart';
import 'package:user_app/utill/dimensions.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:url_launcher/url_launcher.dart';

/// Copied verbatim from https://shop.meatsokogroup.com/business-page/terms-and-conditions
/// on 2026-09-09. Bundled directly in the app (rather than fetched live from
/// the backend's business-pages API, the way the generic HTML-view screen
/// does) so this page is always reachable even if that content is ever
/// missing/misconfigured server-side.
const String _termsAndConditionsHtml = '''<p>Welcome to Meatsoko! These Terms and Conditions govern your use of the Meatsoko website (meatsokgroup.com), mobile applications, and any related delivery services or franchise portals operated by Meatsoko Ecosystem Limited.</p><p>By accessing our services, creating an account, or purchasing products, you agree to be bound by these terms. If you do not agree, please do not use our services.</p><p><br></p><p><br></p><p>1. Account Eligibility and Security</p><ol><li data-list="bullet"><span class="ql-ui" contenteditable="false"></span><strong>Age Requirement:</strong> You must be at least 18 years old to create an account and place orders.</li><li data-list="bullet"><span class="ql-ui" contenteditable="false"></span><strong>Accuracy:</strong> You agree to provide accurate, current, and complete details (name, delivery address, and phone number) during registration.</li><li data-list="bullet"><span class="ql-ui" contenteditable="false"></span><strong>Credentials:</strong> You are responsible for safeguarding your login credentials. Meatsoko is not liable for unauthorized account access resulting from your negligence.</li></ol><p><br></p><p>2. Products, Pricing, and Availability</p><ol><li data-list="bullet"><span class="ql-ui" contenteditable="false"></span><strong>Perishable Nature:</strong> Our products consist of fresh livestock and processed meats. Subtle variances in exact cuts and weight may occur during packaging.</li><li data-list="bullet"><span class="ql-ui" contenteditable="false"></span><strong>Pricing Changes:</strong> Prices for our items are subject to change without notice based on market livestock rates.</li><li data-list="bullet"><span class="ql-ui" contenteditable="false"></span><strong>Stock Limitations:</strong> All orders are subject to product availability. If a specific meat cut is unavailable after an order is placed, our support team will contact you to offer an alternative or a refund.</li></ol><p><br></p><p>3. Payments and Billing</p><ol><li data-list="bullet"><span class="ql-ui" contenteditable="false"></span><strong>Supported Channels:</strong> We accept mobile money transactions (primarily M-Pesa), credit/debit cards, and approved corporate credit accounts.</li><li data-list="bullet"><span class="ql-ui" contenteditable="false"></span><strong>Verification:</strong> Payment must be successfully cleared and confirmed before an order enters processing and cold-chain dispatch.</li><li data-list="bullet"><span class="ql-ui" contenteditable="false"></span><strong>Taxation:</strong> Where applicable, prices listed on our platforms are inclusive of statutory Value Added Tax (VAT) in accordance with Kenyan tax laws.</li></ol><p><br></p><p>4. Logistics, Delivery, and Risk</p><ol><li data-list="bullet"><span class="ql-ui" contenteditable="false"></span><strong>Delivery Zones:</strong> We deliver within designated zones in Nairobi and surrounding metropolitan areas.</li><li data-list="bullet"><span class="ql-ui" contenteditable="false"></span><strong>Timelines:</strong> While we aim for prompt delivery within stated windows, external factors like traffic or weather may cause delays.</li><li data-list="bullet"><span class="ql-ui" contenteditable="false"></span><strong>Transfer of Risk:</strong> Risk of damage or spoilage transfers to the customer immediately upon physical delivery to the specified address. It is the customer's responsibility to refrigerate items immediately.</li></ol><p><br></p><p>5. Return, Cancellation, and Refund Policy</p><ol><li data-list="bullet"><span class="ql-ui" contenteditable="false"></span><strong>Inspection on Delivery:</strong> Due to strict health, hygiene, and perishable goods regulations, you must inspect your meat order immediately upon delivery.</li><li data-list="bullet"><span class="ql-ui" contenteditable="false"></span><strong>Rejections:</strong> If a product arrives damaged, spoiled, or incorrect, you must reject it at the point of delivery and notify the courier immediately.</li><li data-list="bullet"><span class="ql-ui" contenteditable="false"></span><strong>Final Sale:</strong> Once a delivery is accepted and signed for, items cannot be returned, exchanged, or refunded due to food safety protocols.</li></ol><p><br></p><p>6. Franchise and Business Use</p><ol><li data-list="bullet"><span class="ql-ui" contenteditable="false"></span><strong>Independent Portals:</strong> Business users accessing our B2B wholesale portals or franchise toolkits are subject to additional, independent commercial agreements.</li><li data-list="bullet"><span class="ql-ui" contenteditable="false"></span><strong>IP Protection:</strong> The Meatsoko name, the "Meatsoko Ecosystem" logo, website designs, and platform code are protected intellectual property and may not be reused without written consent.</li></ol><p><br></p><p>7. Limitation of Liability</p><p>Meatsoko Ecosystem Limited, its directors, and employees shall not be liable for any indirect, incidental, or consequential damages resulting from the consumption of incorrectly stored meats, delivery delays beyond our control, or temporary website downtime.</p><p><br></p><p>8. Governing Law</p><p>These Terms and Conditions are governed by and construed in accordance with the laws of the Republic of Kenya. Any disputes arising under these terms shall be subject to the exclusive jurisdiction of the courts in Nairobi.</p><p><br></p><p>9. Changes to These Terms</p><p>We reserve the right to update these terms at any time. Changes take effect immediately upon posting to this website. Your continued use of the platform constitutes agreement to the updated terms.</p><p><br></p>''';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      body: Column(children: [
        CustomAppBar(title: getTranslated('terms_condition', context) ?? 'Terms and Conditions'),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Dimensions.homePagePadding),
            physics: const BouncingScrollPhysics(),
            child: HtmlWidget(
              _termsAndConditionsHtml,
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
