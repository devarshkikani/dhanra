import 'package:dhanra/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:dhanra/core/services/local_storage_service.dart';
import 'package:dhanra/features/auth/signup_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
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
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const SignupPage(),
          ),
        );
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
                      title: 'Welcome to Dhanra!',
                      description:
                          'Your personal finance manager. Track your expenses and manage your money with ease.',
                    ),
                    OnboardingStep(
                      image: 'assets/images/d_logo.png',
                      title: 'Automatic SMS Parsing',
                      description:
                          'Dhanra automatically reads your transaction SMS to categorize your spending without any manual effort.',
                    ),
                    OnboardingStep(
                      image: 'assets/images/d_logo.png',
                      title: 'Gain Financial Insights',
                      description:
                          'Get detailed reports and insights into your financial habits to help you save more and spend smarter.',
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

class OnboardingStep extends StatelessWidget {
  final String image;
  final String title;
  final String description;

  const OnboardingStep({
    super.key,
    required this.image,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          description,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
      ],
    );
  }
}
