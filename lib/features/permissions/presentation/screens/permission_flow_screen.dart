import 'package:dhanra/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../../domain/services/permission_service.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../sms_fetching/presentation/sms_fetching_features_screen.dart';

class PermissionFlowScreen extends StatefulWidget {
  const PermissionFlowScreen({Key? key}) : super(key: key);

  @override
  State<PermissionFlowScreen> createState() => _PermissionFlowScreenState();
}

class _PermissionFlowScreenState extends State<PermissionFlowScreen> {
  final PermissionService _permissionService = PermissionService();
  final LocalStorageService _storage = LocalStorageService();

  bool _isLoading = false;
  int _currentStep = 0;
  bool _smsPermissionGranted = false;
  bool _locationPermissionGranted = false;
  bool _notificationPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkExistingPermissions();
    });
  }

  Future<void> _checkExistingPermissions() async {
    _isLoading = true;

    try {
      // Check existing permissions from storage
      _smsPermissionGranted = _storage.smsPermissionGranted;
      _locationPermissionGranted = _storage.locationPermissionGranted;
      _notificationPermissionGranted = _storage.notificationPermissionGranted;

      // If all permissions are already granted, skip to loading screen
      if (_smsPermissionGranted &&
          _locationPermissionGranted &&
          _notificationPermissionGranted) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const SmsFetchingFeaturesScreen(
                hasPermissions: true,
              ),
            ),
          );
        }
        return;
      }

      // Set current step to first ungranted permission
      if (!_smsPermissionGranted) {
        _currentStep = 0;
      } else if (!_locationPermissionGranted) {
        _currentStep = 1;
      } else if (!_notificationPermissionGranted) {
        _currentStep = 2;
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
      await _storage.setSmsPermission(granted);

      setState(() {
        _smsPermissionGranted = granted;
      });

      if (granted &&
          _locationPermissionGranted &&
          _notificationPermissionGranted) {
        _navigateToLoading();
      }
    } finally {
      if (mounted) {
        setState(() {
          _currentStep = 1;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _requestLocationPermission() async {
    setState(() => _isLoading = true);

    try {
      final granted = await _permissionService.requestLocationPermission();
      await _storage.setLocationPermission(granted);

      setState(() {
        _locationPermissionGranted = granted;
      });

      if (granted && _smsPermissionGranted && _notificationPermissionGranted) {
        _navigateToLoading();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _currentStep = 2;
        });
      }
    }
  }

  Future<void> _requestNotificationPermission() async {
    setState(() => _isLoading = true);

    try {
      final granted = await _permissionService.requestNotificationPermission();
      await _storage.setNotificationPermission(granted);

      setState(() {
        _notificationPermissionGranted = granted;
      });

      // if (granted) {
      _navigateToLoading();
      // }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToLoading() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => SmsFetchingFeaturesScreen(
          hasPermissions: _smsPermissionGranted,
        ),
      ),
    );
  }

  void _skipPermission() {
    setState(() {
      _currentStep++;
    });

    if (_currentStep >= 3) {
      _navigateToLoading();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Progress indicator
              LinearProgressIndicator(
                value: (_currentStep + 1) / 3,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 32),

              // Step indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStepIndicator(0, 'SMS', _smsPermissionGranted),
                  _buildStepIndicator(
                      1, 'Location', _locationPermissionGranted),
                  _buildStepIndicator(
                      2, 'Notifications', _notificationPermissionGranted),
                ],
              ),
              const SizedBox(height: 48),

              // Current step content
              Expanded(
                child: _buildCurrentStep(),
              ),

              // Navigation buttons
              Row(
                children: [
                  if (_currentStep > 0)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentStep--;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        side: const BorderSide(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleCurrentStep,
                      child: Text(_getCurrentStepButtonText()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, bool completed) {
    final isCurrentStep = _currentStep == step;
    final color = completed
        ? Colors.green
        : isCurrentStep
            ? Theme.of(context).primaryColor
            : Colors.grey;

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Icon(
            completed ? Icons.check : Icons.circle,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isCurrentStep ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildSmsPermissionStep();
      case 1:
        return _buildLocationPermissionStep();
      case 2:
        return _buildNotificationPermissionStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildSmsPermissionStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          "assets/images/text-message.png",
          height: 100,
          color: Colors.white,
        ),
        const SizedBox(height: 24),
        Text(
          'SMS Permission',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        const Text(
          'We need access to your SMS messages to analyze your financial transactions and provide you with insights about your spending patterns.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 24),
        if (_smsPermissionGranted)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade700),
                const SizedBox(width: 8),
                Text(
                  'SMS permission granted',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildLocationPermissionStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          "assets/images/pin.png",
          height: 100,
          color: Colors.white,
        ),
        const SizedBox(height: 24),
        Text(
          'Location Permission',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Location access helps us provide location-based financial insights and better recommendations for nearby services.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 24),
        if (_locationPermissionGranted)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade700),
                const SizedBox(width: 8),
                Text(
                  'Location permission granted',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildNotificationPermissionStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          "assets/images/notification.png",
          height: 100,
          color: Colors.white,
        ),
        const SizedBox(height: 24),
        Text(
          'Notification Permission',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Stay updated with real-time notifications about your transactions, spending alerts, and personalized financial insights.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 24),
        if (_notificationPermissionGranted)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade700),
                const SizedBox(width: 8),
                Text(
                  'Notification permission granted',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _handleCurrentStep() {
    switch (_currentStep) {
      case 0:
        if (!_smsPermissionGranted) {
          _requestSmsPermission();
        } else {
          _skipPermission();
        }
        break;
      case 1:
        if (!_locationPermissionGranted) {
          _requestLocationPermission();
        } else {
          _skipPermission();
        }
        break;
      case 2:
        if (!_notificationPermissionGranted) {
          _requestNotificationPermission();
        } else {
          _skipPermission();
        }
        break;
    }
  }

  String _getCurrentStepButtonText() {
    switch (_currentStep) {
      case 0:
        return _smsPermissionGranted ? 'Next' : 'Grant SMS Permission';
      case 1:
        return _locationPermissionGranted
            ? 'Next'
            : 'Grant Location Permission';
      case 2:
        return _notificationPermissionGranted
            ? 'Continue'
            : 'Grant Notification Permission';
      default:
        return 'Continue';
    }
  }
}
