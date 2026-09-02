import 'package:concentric_transition/concentric_transition.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_app/features/auth/controllers/auth_controller.dart';
import 'package:user_app/features/splash/controllers/splash_controller.dart';
import 'package:user_app/helper/route_healper.dart';
import 'package:user_app/utill/brand_colors.dart';

class _OnboardingPageData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color bgColor;
  final Color textColor;

  const _OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.bgColor,
    required this.textColor,
  });
}

const List<_OnboardingPageData> _onboardingPages = [
  _OnboardingPageData(
    icon: Icons.storefront_outlined,
    title: 'Fresh Meat, Direct from Pastoralists',
    subtitle: 'Quality-inspected beef, goat, and lamb sourced directly from local herders at fair prices.',
    bgColor: BrandColors.burgundy,
    textColor: Colors.white,
  ),
  _OnboardingPageData(
    icon: Icons.verified_outlined,
    title: 'Guaranteed Cold-Chain Freshness',
    subtitle: 'Tracked temperature control from the farm to your doorstep so your meat arrives safe and fresh.',
    bgColor: BrandColors.ochre,
    textColor: BrandColors.burgundyDark,
  ),
  _OnboardingPageData(
    icon: Icons.local_shipping_outlined,
    title: 'Fast Delivery to Your Door',
    subtitle: 'Select your favorite cuts, choose a delivery window, and get top-tier meats delivered hassle-free.',
    bgColor: BrandColors.offWhite,
    textColor: BrandColors.burgundy,
  ),
];

class OnBoardingScreen extends StatefulWidget {
  final Color indicatorColor;
  final Color selectedIndicatorColor;

  const OnBoardingScreen({super.key, this.indicatorColor = Colors.grey, this.selectedIndicatorColor = Colors.black});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _finishOnboarding() {
    Provider.of<SplashController>(context, listen: false).disableIntro();
    Provider.of<AuthController>(context, listen: false).getGuestIdUrl();
    RouterHelper.getDashboardRoute(action: RouteAction.pushNamedAndRemoveUntil);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool onLastPage = _currentPage == _onboardingPages.length - 1;

    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          ConcentricPageView(
            pageController: _pageController,
            colors: _onboardingPages.map((p) => p.bgColor).toList(),
            radius: screenWidth * 0.1,
            itemCount: _onboardingPages.length,
            onChange: (index) => setState(() => _currentPage = index),
            onFinish: _finishOnboarding,
            nextButtonBuilder: (context) => Padding(
              padding: const EdgeInsets.only(left: 3),
              child: Icon(
                Icons.navigate_next,
                size: screenWidth * 0.08,
                color: Colors.black87,
              ),
            ),
            itemBuilder: (index) {
              final page = _onboardingPages[index % _onboardingPages.length];
              return SafeArea(child: _OnboardingPage(page: page));
            },
          ),

          if (!onLastPage)
            Positioned(
              top: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  child: TextButton(
                    onPressed: _finishOnboarding,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: _onboardingPages[_currentPage].textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingPageData page;

  const _OnboardingPage({required this.page});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: page.textColor,
            ),
            child: Icon(
              page.icon,
              size: screenHeight * 0.09,
              color: page.bgColor,
            ),
          ),
          SizedBox(height: screenHeight * 0.04),
          Text(
            page.title,
            style: TextStyle(
              color: page.textColor,
              fontSize: screenHeight * 0.032,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: screenHeight * 0.015),
          Text(
            page.subtitle,
            style: TextStyle(
              color: page.textColor.withValues(alpha: 0.85),
              fontSize: screenHeight * 0.018,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
