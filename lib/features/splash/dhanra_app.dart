import 'package:dhanra/core/services/local_storage_service.dart';
import 'package:dhanra/core/theme/app_theme.dart';
import 'package:dhanra/features/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dhanra/features/transactions/bloc/transactions_bloc.dart';

class DhanraApp extends StatefulWidget {
  const DhanraApp({super.key});

  @override
  State<DhanraApp> createState() => DhanraAppState();

  static DhanraAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<DhanraAppState>();
}

class DhanraAppState extends State<DhanraApp> {
  late ThemeMode _themeMode;
  final LocalStorageService _storage = LocalStorageService();

  @override
  void initState() {
    super.initState();
    final themeString = _storage.getThemeMode();
    _themeMode =
        ThemeMode.values.firstWhere((e) => e.toString() == themeString);
  }

  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
    _storage.setThemeMode(themeMode.toString());
  }

  ThemeMode getThemeMode() => _themeMode;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TransactionsBloc()..add(const LoadTransactions()),
      child: MaterialApp(
        title: 'Dhanra',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _themeMode,
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
