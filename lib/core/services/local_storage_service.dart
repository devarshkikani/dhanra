import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // User Authentication
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserPhone = 'user_phone';
  static const String _keyUserName = 'user_name';
  static const String _keyUserId = 'user_id';

  // SMS Data
  static const String _keySmsData = 'sms_data';
  static const String _keySmsLastFetch = 'sms_last_fetch';
  static const String _keyTransactionData = 'transaction_data';

  // Permissions
  static const String _keySmsPermission = 'sms_permission';
  static const String _keyLocationPermission = 'location_permission';
  static const String _keyNotificationPermission = 'notification_permission';

  // App Settings
  static const String _keyFirstLaunch = 'first_launch';
  static const String _keyOnboardingComplete = 'onboarding_complete';
  static const String _keyThemeMode = 'theme_mode';

  // User Authentication Methods
  Future<void> setUserLoggedIn({
    required String phone,
    required String name,
    required String userId,
  }) async {
    await _prefs?.setBool(_keyIsLoggedIn, true);
    await _prefs?.setString(_keyUserPhone, phone);
    await _prefs?.setString(_keyUserName, name);
    await _prefs?.setString(_keyUserId, userId);
  }

  Future<void> setUserLoggedOut() async {
    await _prefs?.setBool(_keyIsLoggedIn, false);
    await _prefs?.remove(_keyUserPhone);
    await _prefs?.remove(_keyUserName);
    await _prefs?.remove(_keyUserId);
    // Clear SMS data on logout
    await clearSmsData();
  }

  bool get isLoggedIn => _prefs?.getBool(_keyIsLoggedIn) ?? false;
  String get userPhone => _prefs?.getString(_keyUserPhone) ?? '';
  String get userName => _prefs?.getString(_keyUserName) ?? '';
  String get userId => _prefs?.getString(_keyUserId) ?? '';

  // SMS Data Management
  Future<void> saveSmsData(List<Map<String, dynamic>> smsData) async {
    final jsonData = jsonEncode(smsData);
    await _prefs?.setString(_keySmsData, jsonData);
    await _prefs?.setInt(
        _keySmsLastFetch, DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> saveTransactionData(
      List<Map<String, dynamic>> transactionData) async {
    final jsonData = jsonEncode(transactionData);
    await _prefs?.setString(_keyTransactionData, jsonData);
  }

  List<Map<String, dynamic>> getSmsData() {
    final jsonData = _prefs?.getString(_keySmsData);
    if (jsonData != null) {
      final List<dynamic> decoded = jsonDecode(jsonData);
      return decoded.cast<Map<String, dynamic>>();
    }
    return [];
  }

  List<Map<String, dynamic>> getTransactionData() {
    final jsonData = _prefs?.getString(_keyTransactionData);
    if (jsonData != null) {
      final List<dynamic> decoded = jsonDecode(jsonData);
      return decoded.cast<Map<String, dynamic>>();
    }
    return [];
  }

  DateTime? getSmsLastFetchTime() {
    final timestamp = _prefs?.getInt(_keySmsLastFetch);
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return null;
  }

  bool get hasSmsData {
    final lastFetch = getSmsLastFetchTime();
    if (lastFetch == null) return false;

    // Check if data is less than 24 hours old
    final now = DateTime.now();
    final difference = now.difference(lastFetch);
    return difference.inHours < 24;
  }

  Future<void> clearSmsData() async {
    await _prefs?.remove(_keySmsData);
    await _prefs?.remove(_keySmsLastFetch);
    await _prefs?.remove(_keyTransactionData);
  }

  // Permissions Management
  Future<void> setSmsPermission(bool granted) async {
    await _prefs?.setBool(_keySmsPermission, granted);
  }

  Future<void> setLocationPermission(bool granted) async {
    await _prefs?.setBool(_keyLocationPermission, granted);
  }

  Future<void> setNotificationPermission(bool granted) async {
    await _prefs?.setBool(_keyNotificationPermission, granted);
  }

  bool get smsPermissionGranted => _prefs?.getBool(_keySmsPermission) ?? false;
  bool get locationPermissionGranted =>
      _prefs?.getBool(_keyLocationPermission) ?? false;
  bool get notificationPermissionGranted =>
      _prefs?.getBool(_keyNotificationPermission) ?? false;

  bool get allPermissionsGranted {
    return smsPermissionGranted &&
        locationPermissionGranted &&
        notificationPermissionGranted;
  }

  // App Settings
  Future<void> setFirstLaunch(bool isFirst) async {
    await _prefs?.setBool(_keyFirstLaunch, isFirst);
  }

  Future<void> setOnboardingComplete(bool complete) async {
    await _prefs?.setBool(_keyOnboardingComplete, complete);
  }

  bool get isFirstLaunch => _prefs?.getBool(_keyFirstLaunch) ?? true;
  bool get isOnboardingComplete =>
      _prefs?.getBool(_keyOnboardingComplete) ?? false;

  // Theme Management
  Future<void> setThemeMode(String themeMode) async {
    await _prefs?.setString(_keyThemeMode, themeMode);
  }

  String getThemeMode() {
    return _prefs?.getString(_keyThemeMode) ?? 'ThemeMode.dark';
  }

  // Monthly Data Management
  Future<void> saveMonthlyData(
      String month, List<Map<String, dynamic>> data) async {
    final key = 'monthly_data_$month';
    final jsonData = jsonEncode(data);
    await _prefs?.setString(key, jsonData);
  }

  List<Map<String, dynamic>> getMonthlyData(String month) {
    final key = 'monthly_data_$month';
    final jsonData = _prefs?.getString(key);
    if (jsonData != null) {
      final List<dynamic> decoded = jsonDecode(jsonData);
      return decoded.cast<Map<String, dynamic>>();
    }
    return [];
  }

  List<String> getAvailableMonths() {
    final keys = _prefs?.getKeys() ?? {};
    final monthlyKeys = keys.where((key) => key.startsWith('monthly_data_'));
    return monthlyKeys
        .map((key) => key.replaceFirst('monthly_data_', ''))
        .toList();
  }

  Future<void> addTransaction(Map<String, dynamic> transaction) async {
    final dateStr = transaction['date'];
    if (dateStr == null) return;

    // Assuming date is in a format that can be parsed.
    // E.g., millisecondsSinceEpoch as a string, or 'yyyy-MM-dd'.
    DateTime date;
    try {
      // Try parsing from milliseconds since epoch
      date = DateTime.fromMillisecondsSinceEpoch(int.parse(dateStr));
    } catch (e) {
      // Try parsing from a formatted string like 'dd-MM-yyyy' or 'yyyy-MM-dd'
      try {
        date = DateFormat('dd-MM-yyyy').parse(dateStr);
      } catch (e2) {
        // Add more formats if needed
        return; // Cannot parse date, so cannot save.
      }
    }

    final monthKey = DateFormat('yyyy-MM').format(date);
    final monthlyData = getMonthlyData(monthKey);
    monthlyData.add(transaction);

    // Sort by date after adding
    monthlyData.sort((a, b) {
      try {
        final dateA = DateTime.fromMillisecondsSinceEpoch(int.parse(a['date']));
        final dateB = DateTime.fromMillisecondsSinceEpoch(int.parse(b['date']));
        return dateB.compareTo(dateA); // Descending order
      } catch (e) {
        return 0;
      }
    });

    await saveMonthlyData(monthKey, monthlyData);
  }

  Future<void> updateTransaction(Map<String, dynamic> transaction) async {
    final dateStr = transaction['date'];
    if (dateStr == null) return;

    DateTime date;
    try {
      date = DateTime.fromMillisecondsSinceEpoch(int.parse(dateStr));
    } catch (e) {
      try {
        date = DateFormat('dd-MM-yyyy').parse(dateStr);
      } catch (e2) {
        return;
      }
    }

    final monthKey = DateFormat('yyyy-MM').format(date);
    final monthlyData = getMonthlyData(monthKey);
    final index = monthlyData.indexWhere((t) => t['id'] == transaction['id']);

    if (index != -1) {
      monthlyData[index] = transaction;
      await saveMonthlyData(monthKey, monthlyData);
    }
  }

  Future<void> deleteTransaction(String transactionId, String monthKey) async {
    final monthlyData = getMonthlyData(monthKey);
    monthlyData.removeWhere((t) => t['id'] == transactionId);
    await saveMonthlyData(monthKey, monthlyData);
  }

  // Utility Methods
  Future<void> clearAllData() async {
    await _prefs?.clear();
  }

  Future<void> clearUserData() async {
    await setUserLoggedOut();
    await clearSmsData();
  }
}
