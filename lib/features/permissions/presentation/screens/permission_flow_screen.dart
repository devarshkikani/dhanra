import 'package:dhanra/core/routing/route_names.dart';
import 'package:dhanra/core/services/local_storage_service.dart';
import 'package:dhanra/core/theme/app_colors.dart';
import 'package:dhanra/features/permissions/domain/services/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionFlowScreen extends StatefulWidget {
  const PermissionFlowScreen({super.key});

  @override
  State<PermissionFlowScreen> createState() => _PermissionFlowScreenState();
}

class _PermissionFlowScreenState extends State<PermissionFlowScreen> {
  final PermissionService _permissionService = PermissionService();
  final LocalStorageService _storage = LocalStorageService();

  bool _isLoading = false;
  bool _isPermissionPermanentlyDenied = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkExistingPermission();
    });
  }

  Future<void> _checkExistingPermission() async {
    setState(() => _isLoading = true);

    try {
      final status = await Permission.sms.status;
      final hasPermission = status.isGranted;

      await _storage.setSmsPermission(hasPermission);

      if (!mounted) return;

      setState(() {
        _isPermissionPermanentlyDenied = status.isPermanentlyDenied;
      });

      if (hasPermission) {
        _goToSmsImport();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _requestSmsPermission() async {
    setState(() => _isLoading = true);

    try {
      final granted = await _permissionService.requestSMSPermission();
      final status = await Permission.sms.status;

      await _storage.setSmsPermission(granted);

      if (!mounted) return;

      setState(() {
        _isPermissionPermanentlyDenied = status.isPermanentlyDenied;
      });

      if (granted) {
        _goToSmsImport();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _goToSmsImport() {
    context.go(
      AppRoute.smsFetchingFeatures.path,
      extra: {
        'hasPermissions': true,
        'nextPath':
            _storage.isLoggedIn ? AppRoute.home.path : AppRoute.signup.path,
      },
    );
  }

  void _continueWithoutSms() {
    context.go(_storage.isLoggedIn ? AppRoute.home.path : AppRoute.signup.path);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomCenter,
            colors: [
              theme.primaryColor.withAlpha(36),
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                Text(
                  'Enable SMS Auto-Tracking',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Dhanra reads bank transaction SMS alerts to automatically track your expenses and income. This is the core feature of the app.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Center(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(14),
                            blurRadius: 28,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Container(
                          //   height: 88,
                          //   width: 88,
                          //   decoration: BoxDecoration(
                          //     color: theme.primaryColor.withAlpha(18),
                          //     shape: BoxShape.circle,
                          //   ),
                          //   child: Icon(
                          //     Icons.sms_rounded,
                          //     size: 42,
                          //     color: theme.primaryColor,
                          //   ),
                          // ),
                          // const SizedBox(height: 24),
                          Text(
                            'Why we need SMS access',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.primaryColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          _BenefitRow(
                            icon: Icons.account_balance_wallet_outlined,
                            text:
                                'We scan transactional bank SMS messages already on your phone.',
                          ),
                          _BenefitRow(
                            icon: Icons.swap_vert_circle_outlined,
                            text:
                                'Debit and credit alerts are converted into expense and income entries automatically.',
                          ),
                          _BenefitRow(
                            icon: Icons.insights_outlined,
                            text:
                                'Your dashboard is prepared instantly without manual transaction entry.',
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.green.shade100),
                            ),
                            child: Text(
                              'We only use SMS access for financial transaction tracking.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.green.shade800,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (_isPermissionPermanentlyDenied) ...[
                            const SizedBox(height: 16),
                            Text(
                              'SMS permission is blocked. Open system settings and enable SMS access to restore automatic expense tracking.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.orange.shade800,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading
                      ? null
                      : _isPermissionPermanentlyDenied
                          ? _permissionService.openSystemAppSettings
                          : _requestSmsPermission,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  icon: Icon(
                    _isPermissionPermanentlyDenied
                        ? Icons.settings_outlined
                        : Icons.lock_open_rounded,
                  ),
                  label: Text(
                    _isPermissionPermanentlyDenied
                        ? 'Open Settings'
                        : 'Allow SMS Access',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _isLoading ? null : _continueWithoutSms,
                  child: const Text('Continue without SMS for now'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BenefitRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.45,
                    color: Colors.grey.shade800,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
