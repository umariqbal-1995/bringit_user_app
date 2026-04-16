import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;

  const OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final _controller = PageController();
  int _current = 0;

  final _pages = const [
    OnboardingPage(
      title: 'Order from your favorite restaurants',
      description:
          'Discover thousands of restaurants near you and get food delivered to your doorstep in minutes.',
      icon: Icons.restaurant_outlined,
    ),
    OnboardingPage(
      title: 'Shop from local stores',
      description:
          'Browse products from nearby supermarkets and stores. Everything delivered fast.',
      icon: Icons.storefront_outlined,
    ),
    OnboardingPage(
      title: 'Track your order live',
      description:
          'Real-time tracking so you always know where your order is.',
      icon: Icons.location_on_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _current = i),
                itemCount: _pages.length,
                itemBuilder: (_, i) => _OnboardingPageWidget(page: _pages[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _current ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _current
                              ? AppColors.primary
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      if (_current < _pages.length - 1) {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        Get.offAllNamed(AppRoutes.sendOtp);
                      }
                    },
                    child: Text(
                        _current < _pages.length - 1 ? 'Next' : 'Get Started'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Get.offAllNamed(AppRoutes.sendOtp),
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageWidget extends StatelessWidget {
  final OnboardingPage page;
  const _OnboardingPageWidget({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(page.icon, size: 72, color: AppColors.primary),
          ),
          const SizedBox(height: 48),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
