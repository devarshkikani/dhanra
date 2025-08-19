import 'package:dhanra/features/transactions/presentation/bloc/transaction_cubit.dart';
import 'package:dhanra/features/transactions/presentation/bloc/transaction_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../home/presentation/screens/home_screen.dart';
import '../../domain/services/permission_service.dart';

class LoadingFeaturesScreen extends StatelessWidget {
  final bool hasPermissions;

  const LoadingFeaturesScreen({
    Key? key,
    required this.hasPermissions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = TransactionCubit();
        if (hasPermissions && cubit.state.status == TransactionStatus.initial) {
          cubit.fetchAndProcessSms();
        }
        return cubit;
      },
      child: const LoadingFeaturesView(),
    );
  }
}

class LoadingFeaturesView extends StatefulWidget {
  const LoadingFeaturesView({Key? key}) : super(key: key);

  @override
  State<LoadingFeaturesView> createState() => _LoadingFeaturesViewState();
}

class _LoadingFeaturesViewState extends State<LoadingFeaturesView> {
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
    return BlocListener<TransactionCubit, TransactionState>(
      listener: (context, state) {
        if (state.status == TransactionStatus.success ||
            state.status == TransactionStatus.failure) {
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(),
                ),
              );
            }
          });
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: BlocBuilder<TransactionCubit, TransactionState>(
                builder: (context, state) {
              final isPermissionError =
                  state.statusMessage.toLowerCase().contains('permission');
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      _features[_currentFeatureIndex],
                      key: ValueKey(_currentFeatureIndex),
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 48),
                  if (state.statusMessage.isNotEmpty)
                    Text(
                      state.statusMessage,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  if (state.status == TransactionStatus.loading) ...[
                    const SizedBox(height: 24),
                    const CircularProgressIndicator(),
                    if (state.totalSmsCount > 0) ...[
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: state.processedSmsCount / state.totalSmsCount,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${state.processedSmsCount}/${state.totalSmsCount}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ] else if (isPermissionError) ...[
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => _permissionService.openAppSettings(),
                      child: const Text('Open Settings'),
                    ),
                  ],
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
