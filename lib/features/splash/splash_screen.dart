import 'package:another_telephony/telephony.dart';
import 'package:dhanra/core/routing/route_names.dart';
import 'package:dhanra/core/services/local_storage_service.dart';
import 'package:dhanra/core/services/sms_parser_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Splash screen that handles app initialization and navigation logic
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const Duration _splashDelay = Duration(seconds: 2);
  static const String _appLogoPath = 'assets/images/dhanra.png';
  static const String _appTagline = 'Your Personal Finance Manager';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// Initialize app and handle navigation based on user state
  Future<void> _initializeApp() async {
    try {
      // Show splash screen for minimum duration
      await Future.delayed(_splashDelay);

      if (!mounted) return;

      await _navigateBasedOnUserState();
    } catch (error) {
      _handleInitializationError(error);
    }
  }

  /// Navigate user based on authentication and onboarding status
  Future<void> _navigateBasedOnUserState() async {
    final storage = LocalStorageService();

    if (storage.isLoggedIn) {
      await _performBackgroundTasks();
      _navigateToHome();
    } else if (storage.isOnboardingComplete) {
      _navigateToLogin();
    } else {
      _navigateToOnboarding();
    }
  }

  /// Perform background tasks for authenticated users
  Future<void> _performBackgroundTasks() async {
    try {
      await _backfillSmsSinceLastTransaction();
    } catch (error) {
      // Log error but don't block navigation
      debugPrint('Background task failed: $error');
    }
  }

  /// Backfill SMS data since last transaction
  Future<void> _backfillSmsSinceLastTransaction() async {
    final storage = LocalStorageService();
    final lastTimestamp = storage.getLastTransactionTimestamp();

    // Skip backfill if no prior data exists
    if (lastTimestamp <= 0) return;

    final messages = await _fetchRecentSmsMessages(lastTimestamp);
    if (messages.isEmpty) return;

    await _processSmsMessages(messages, storage);
  }

  /// Fetch SMS messages newer than the given timestamp
  Future<List<SmsMessage>> _fetchRecentSmsMessages(int lastTimestamp) async {
    final telephony = Telephony.instance;

    final allMessages = await telephony.getInboxSms(
      columns: [
        SmsColumn.ID,
        SmsColumn.ADDRESS,
        SmsColumn.BODY,
        SmsColumn.DATE,
      ],
    );

    // Filter messages by timestamp
    return allMessages
        .where((message) => (message.date ?? 0) > lastTimestamp)
        .toList();
  }

  /// Process SMS messages and save transaction data
  Future<void> _processSmsMessages(
    List<SmsMessage> messages,
    LocalStorageService storage,
  ) async {
    final parser = SmsParserService.instance;

    await parser.parseTransactionMessagesFlexible(
      messages,
      onProgress: (processed, total, found, month, results) async {
        await _saveMonthlyTransactionData(storage, month, results);
      },
    );
  }

  /// Save monthly transaction data with deduplication
  Future<void> _saveMonthlyTransactionData(
    LocalStorageService storage,
    String month,
    List<Map<String, String>> newResults,
  ) async {
    final existingData = storage.getMonthlyData(month);
    final combinedData = _mergeDeduplicate(existingData, newResults);
    storage.saveMonthlyData(month, combinedData);
  }

  /// Merge and deduplicate transaction data
  List<Map<String, dynamic>> _mergeDeduplicate(
    List<Map<String, dynamic>> existing,
    List<Map<String, String>> newData,
  ) {
    final converted =
        newData.map((item) => item.cast<String, dynamic>()).toList();

    final combined = [...converted, ...existing];
    final seen = <String>{};

    return combined.where((item) {
      final id = item['id']?.toString();
      if (id == null || seen.contains(id)) return false;
      seen.add(id);
      return true;
    }).toList();
  }

  /// Navigation methods using GoRouter
  void _navigateToHome() => _navigateTo(AppRoute.home.path);
  void _navigateToLogin() => _navigateTo(AppRoute.login.path);
  void _navigateToOnboarding() => _navigateTo(AppRoute.onboarding.path);

  void _navigateTo(String path) {
    if (!mounted) return;

    context.go(path);
  }

  /// Handle initialization errors
  void _handleInitializationError(Object error) {
    debugPrint('Splash screen initialization failed: $error');

    if (mounted) {
      // Fallback to onboarding in case of errors
      _navigateToOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _buildSplashContent(context),
            ),
            // Uncomment if you want to add loading animation
            _buildLoadingIndicator(),
          ],
        ),
      ),
    );
  }

  /// Build the main splash screen content
  Widget _buildSplashContent(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 50),
          _buildAppLogo(),
          const SizedBox(height: 20),
          _buildTagline(theme),
        ],
      ),
    );
  }

  /// Build app logo with error handling
  Widget _buildAppLogo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50.0),
      child: Image.asset(
        _appLogoPath,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.account_balance_wallet,
            size: 80,
            color: Colors.blue,
          );
        },
      ),
    );
  }

  /// Build app tagline
  Widget _buildTagline(ThemeData theme) {
    return Text(
      _appTagline,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: theme.colorScheme.onSurface.withAlpha(150),
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Optional loading indicator
  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(32.0),
      child: CircularProgressIndicator(),
    );
  }
}
