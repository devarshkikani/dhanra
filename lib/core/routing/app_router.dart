// lib/core/routing/app_router.dart
import 'package:dhanra/features/home/presentation/home_screen.dart';
import 'package:dhanra/features/investment/models/investment_option.dart';
import 'package:dhanra/features/investment/widgets/risk_category_widget.dart';
import 'package:dhanra/features/onboarding/onboarding_screen.dart';
import 'package:dhanra/features/permissions/presentation/screens/permission_flow_screen.dart';
import 'package:dhanra/features/sms_fetching/presentation/sms_fetching_features_screen.dart';
import 'package:dhanra/features/splash/splash_screen.dart';
import 'package:dhanra/features/stats_screen/presentation/category_details_screen.dart';
import 'package:dhanra/features/transactions/presentation/add_edit_transaction_screen.dart';
import 'package:dhanra/features/transactions/presentation/all_transactions_screen.dart';
import 'package:dhanra/features/transactions/presentation/bank_transactions_screen.dart';
import 'package:dhanra/features/transactions/presentation/banks_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Import your screens
import '../../features/auth/login_screen.dart';
import '../../features/auth/signup_screen.dart';
import '../../features/auth/otp_verification_screen.dart';
import '../../features/profile/profile_screen.dart';

import 'route_names.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoute.splash.path,
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: AppRoute.splash.path,
      name: AppRoute.splash.name,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoute.onboarding.path,
      name: AppRoute.onboarding.name,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoute.login.path,
      name: AppRoute.login.name,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoute.signup.path,
      name: AppRoute.signup.name,
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: AppRoute.otpVerification.path,
      name: AppRoute.otpVerification.name,
      builder: (context, state) {
        final phoneNumber = state.extra as Map<String, dynamic>?;
        return OtpVerificationScreen(
          phoneNumber: phoneNumber?['phoneNumber'] ?? "",
          userName: phoneNumber?['userName'] ?? "",
          isSignup: phoneNumber?['isSignup'] ?? false,
          verificationId: phoneNumber?['verificationId'] ?? "",
        );
      },
    ),
    GoRoute(
      path: AppRoute.home.path,
      name: AppRoute.home.name,
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'profile',
          name: AppRoute.homeProfile.name,
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: 'transactions',
          name: AppRoute.homeTransactions.name,
          builder: (context, state) => const AllTransactionsScreen(
            banks: [],
          ),
        ),
      ],
    ),
    GoRoute(
      path: AppRoute.profile.path,
      name: AppRoute.profile.name,
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: AppRoute.transactions.path,
      name: AppRoute.transactions.name,
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return AllTransactionsScreen(
          banks: data['banks'] ?? [],
        );
      },
    ),
    GoRoute(
      path: AppRoute.addEditTransaction.path,
      name: AppRoute.addEditTransaction.name,
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return AddEditTransactionScreen(
          banks: data['banks'] ?? [],
          transaction: data['transaction'] ?? {},
        );
      },
    ),
    GoRoute(
        path: AppRoute.banksList.path,
        name: AppRoute.banksList.name,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return BanksListScreen(
            banks: data['banks'] ?? [],
          );
        }),
    GoRoute(
      path: AppRoute.bankTransactions.path,
      name: AppRoute.bankTransactions.name,
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return BankTransactionsScreen(
          bank: data['bank'] ?? '',
          banks: data['banks'] ?? [],
        );
      },
    ),
    GoRoute(
      path: AppRoute.investmentDetails.path,
      name: AppRoute.investmentDetails.name,
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return InvestmentDetailsScreen(
          option: data['option'] ??
              InvestmentOption(
                name: '',
                description: '',
                potentialReturn: 0,
                risk: 0,
                riskLevel: RiskLevel.low,
              ),
          userAmount: data['userAmount'] ?? 0.0,
        );
      },
    ),
    GoRoute(
      path: AppRoute.categoryDetails.path,
      name: AppRoute.categoryDetails.name,
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return CategoryDetailsScreen(
          // categoryId: categoryId,
          category: data['category'],
          period: data['period'],
          startDate: data['startDate'],
          endDate: data['endDate'],
          type: data['type'],
        );
      },
    ),
    GoRoute(
        path: AppRoute.smsFetchingFeatures.path,
        name: AppRoute.smsFetchingFeatures.name,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return SmsFetchingFeaturesScreen(
            hasPermissions: data['hasPermissions'] ?? false,
          );
        }),
    GoRoute(
      path: AppRoute.permission.path,
      name: AppRoute.permission.name,
      builder: (context, state) => const PermissionFlowScreen(),
    ),
  ],
);
