// lib/core/routing/route_names.dart
enum AppRoute {
  splash,
  onboarding,
  login,
  signup,
  home,
  profile,
  // settings,
  transactions,
  addEditTransaction,

  // Nested routes
  homeTransactions,
  homeProfile,

  permission,
  otpVerification,
  banksList,
  bankTransactions,
  investmentDetails,
  smsFetchingFeatures,
  categoryDetails,
}

extension AppRouteExtension on AppRoute {
  String get path {
    switch (this) {
      case AppRoute.splash:
        return '/';
      case AppRoute.onboarding:
        return '/onboarding';
      case AppRoute.login:
        return '/login';
      case AppRoute.signup:
        return '/signup';
      case AppRoute.home:
        return '/home';
      case AppRoute.profile:
        return '/profile';
      case AppRoute.transactions:
        return '/transactions';
      case AppRoute.addEditTransaction:
        return '/add-edit-transaction';

      // Nested
      case AppRoute.homeTransactions:
        return '/home/transactions';
      case AppRoute.homeProfile:
        return '/home/profile';

      case AppRoute.permission:
        return '/permission';
      case AppRoute.otpVerification:
        return '/otp-verification';
      case AppRoute.banksList:
        return '/banks-list';
      case AppRoute.bankTransactions:
        return '/bank-transactions';
      case AppRoute.investmentDetails:
        return '/investment-details';
      case AppRoute.smsFetchingFeatures:
        return '/sms-fetching-features';
      case AppRoute.categoryDetails:
        return '/category-details';
    }
  }

  String get name => toString().split('.').last;
}
