import 'package:dhanra/core/services/local_storage_service.dart';
import 'package:dhanra/core/services/sms_parser_service.dart';
import 'package:another_telephony/telephony.dart';
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
        await _backfillSmsSinceLastTransaction();
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

  Future<void> _backfillSmsSinceLastTransaction() async {
    try {
      final storage = LocalStorageService();
      final telephony = Telephony.instance;
      final parser = SmsParserService.instance;

      final lastTs = storage.getLastTransactionTimestamp();
      // If we have no prior data, skip backfill to avoid heavy fetch at splash
      if (lastTs <= 0) return;

      final List<SmsMessage> messages = await telephony.getInboxSms(
        columns: [
          SmsColumn.ID,
          SmsColumn.ADDRESS,
          SmsColumn.BODY,
          SmsColumn.DATE,
        ],
        // Fetch only messages newer than last known transaction
        // Telephony package doesn't support direct since filtering,
        // so we filter in-memory after fetch.
      );

      // Filter messages by date > lastTs
      final recentMessages = messages.where((m) {
        final ts = m.date ?? 0;
        return ts > lastTs;
      }).toList();

      if (recentMessages.isEmpty) return;

      // Convert → parse by month → persist using existing flow
      await parser.parseTransactionMessagesFlexible(
        recentMessages,
        onProgress: (processed, total, found, month, results) async {
          // Save month batch results
          List<Map<String, String>> newResults = results;
          final List<Map<String, dynamic>> monthlyMessages =
              storage.getMonthlyData(month);

          List<Map<String, dynamic>> convertedResults = newResults
              .map((map) => map.map((key, value) => MapEntry(key, value)))
              .toList();

          List<Map<String, dynamic>> combined = [
            ...convertedResults,
            ...monthlyMessages
          ];
          Set<String> seenIds = {};
          List<Map<String, dynamic>> uniqueList = [];

          for (var map in combined) {
            String? id = map['id']?.toString();
            if (id != null && !seenIds.contains(id)) {
              seenIds.add(id);
              uniqueList.add(map);
            }
          }
          storage.saveMonthlyData(month, uniqueList);
        },
      );
    } catch (_) {
      // Avoid blocking splash; fail silently
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Theme.of(context).primaryColor,
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 50,
                  ),
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
          ),
          Image.asset(
            "assets/gif/money_stack.gif",
          ),
        ],
      ),
    );
  }
}
