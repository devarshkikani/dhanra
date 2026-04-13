import 'package:dhanra/core/routing/route_names.dart';
import 'package:dhanra/core/theme/app_colors.dart';
import 'package:dhanra/features/onboarding/onboarding_step.dart';
import 'package:flutter/material.dart';
import 'package:dhanra/core/services/local_storage_service.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _onContinue() async {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      final storage = LocalStorageService();
      await storage.setOnboardingComplete(true);
      if (mounted) {
        context.pushReplacement(AppRoute.signup.path);
        // Navigator.of(context).pushReplacement(
        //   MaterialPageRoute(
        //     builder: (context) => const SignupScreen(),
        //   ),
        // );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.center,
              colors: [
                Theme.of(context).primaryColor.withAlpha(50),
                AppColors.background
              ],
            ),
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Image.asset(
                    'assets/images/d_logo.png',
                    height: 180,
                    width: 180,
                  ),
                ),
              ),
              const Spacer(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  children: const [
                    OnboardingStep(
                      image: 'assets/images/d_logo.png',
                      title: 'Track Expenses From Bank SMS',
                      description:
                          'Dhanra reads bank transaction SMS alerts and turns them into expense and income entries automatically.',
                    ),
                    OnboardingStep(
                      image: 'assets/images/d_logo.png',
                      title: 'Enable SMS To Auto-Track',
                      description:
                          'Grant SMS access so we can detect debit and credit alerts, identify the bank, and build your transaction history without manual entry.',
                    ),
                    OnboardingStep(
                      image: 'assets/images/d_logo.png',
                      title: 'See Spending Instantly',
                      description:
                          'Once SMS access is enabled, Dhanra scans your recent transaction messages and prepares your spending insights right away.',
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dots Indicator
                  Row(
                    children: List.generate(
                      3,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        height: 10,
                        width: _currentPage == index ? 24 : 10,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _onContinue,
                    child: Text(_currentPage < 2 ? 'Next' : 'Get Started'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
