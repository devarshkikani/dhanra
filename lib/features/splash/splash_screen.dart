import 'package:dhanra/core/services/local_storage_service.dart';
import 'package:dhanra/features/home/presentation/home_screen.dart';
import 'package:dhanra/features/auth/login_page.dart';
import 'package:dhanra/features/onboarding/onboarding_page.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Simulate splash screen delay
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      final storage = LocalStorageService();

      if (storage.isLoggedIn) {
        // Existing User, Logged In -> HomeScreen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      } else if (storage.isOnboardingComplete) {
        // Existing User, Logged Out -> LoginPage
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
        );
      } else {
        // New User -> OnboardingPage
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const OnboardingPage(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: Image.asset(
                "assets/images/dhanra.png",
              ),
            ),

            const SizedBox(
              height: 20,
            ),
            // App Tagline
            Text(
              'Your Personal Finance Manager',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
