import 'package:dhanra/core/routing/route_names.dart';
import 'package:dhanra/core/theme/gradients.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
// import 'package:lottie/lottie.dart'; // Uncomment if using Lottie
import '../bloc/sms_fetching_features_bloc.dart';
import '../bloc/sms_fetching_features_event.dart';
import '../bloc/sms_fetching_features_state.dart';

// import '../../home/presentation/home_screen.dart';
import '../../permissions/domain/services/permission_service.dart';

class SmsFetchingFeaturesScreen extends StatelessWidget {
  final bool hasPermissions;

  const SmsFetchingFeaturesScreen({
    super.key,
    required this.hasPermissions,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = SmsFetchingFeaturesBloc();
        bloc.add(StartSmsFetching(hasPermissions));
        return bloc;
      },
      child: const SmsFetchingFeaturesView(),
    );
  }
}

class SmsFetchingFeaturesView extends StatefulWidget {
  const SmsFetchingFeaturesView({super.key});

  @override
  State<SmsFetchingFeaturesView> createState() =>
      _SmsFetchingFeaturesViewState();
}

class _SmsFetchingFeaturesViewState extends State<SmsFetchingFeaturesView> {
  final PermissionService _permissionService = PermissionService();

  final List<String> _features = [
    'Stay updated with real-time notifications',
    'Location-based services for better recommendations',
    'Enhanced SMS integration for seamless experience',
    'Personalized content based on your preferences',
  ];

  int _currentFeatureIndex = 0;

  @override
  void initState() {
    super.initState();
    _startFeatureRotation();
  }

  void _startFeatureRotation() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _currentFeatureIndex = (_currentFeatureIndex + 1) % _features.length;
        });
        _startFeatureRotation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return BlocListener<SmsFetchingFeaturesBloc, SmsFetchingFeaturesState>(
      listener: (ctx, state) {
        if (state.status == SmsFetchingStatus.success ||
            state.status == SmsFetchingStatus.failure) {
          if (mounted) {
            context.pushReplacement(AppRoute.home.path);
            // Navigator.of(context).pushReplacement(
            //   MaterialPageRoute(
            //     builder: (context) => const HomeScreen(),
            //   ),
            // );
          }
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Gradients.gradient(
              top: -MediaQuery.of(context).size.height,
              left: -MediaQuery.of(context).size.width,
              right: 0,
              context: context,
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: BlocBuilder<SmsFetchingFeaturesBloc,
                    SmsFetchingFeaturesState>(
                  builder: (context, state) {
                    final isPermissionError = state.statusMessage
                        .toLowerCase()
                        .contains('permission');
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Lottie animation or large icon
                          // Uncomment and add your Lottie asset if available
                          // Lottie.asset('assets/animations/secure.json', height: 120),
                          Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withAlpha(20),
                              ),
                            ),
                            child: const Icon(
                              Icons.sms_rounded,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Feature card
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(15),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: Colors.white.withAlpha(20),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 28),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 500),
                                child: Text(
                                  _features[_currentFeatureIndex],
                                  key: ValueKey(_currentFeatureIndex),
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          if (state.statusMessage.isNotEmpty)
                            Text(
                              state.statusMessage,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          if (state.status == SmsFetchingStatus.loading) ...[
                            const SizedBox(height: 32),
                            SizedBox(
                              width: 48,
                              height: 48,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  colorScheme.secondary,
                                ),
                                strokeWidth: 5,
                              ),
                            ),
                            if (state.totalSmsCount > 0) ...[
                              const SizedBox(height: 24),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  minHeight: 8,
                                  value: state.totalSmsCount > 0
                                      ? state.processedSmsCount /
                                          state.totalSmsCount
                                      : 0,
                                  backgroundColor: colorScheme.primaryContainer
                                      .withValues(alpha: 0.3),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    colorScheme.secondary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${state.processedSmsCount}/${state.totalSmsCount}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ] else if (isPermissionError) ...[
                            const SizedBox(height: 32),
                            ElevatedButton.icon(
                              onPressed: () =>
                                  _permissionService.openAppSettings(),
                              icon: Icon(Icons.settings,
                                  color: colorScheme.onSecondary),
                              label: const Text('Open Settings'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.secondary,
                                foregroundColor: colorScheme.onSecondary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 28, vertical: 14),
                                textStyle:
                                    theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                elevation: 4,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
