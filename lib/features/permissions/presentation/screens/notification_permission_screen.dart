import 'package:flutter/material.dart';
import '../widgets/permission_screen.dart';

class NotificationPermissionScreen extends StatelessWidget {
  final VoidCallback onGrant;
  final VoidCallback onSkip;

  const NotificationPermissionScreen({
    super.key,
    required this.onGrant,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return PermissionScreen(
      title: 'Enable Notifications',
      description:
          'We request access to your Notifications to provide timely updates. '
          'Your data is safe with us and will only be used for enhancing your experience.',
      icon: Icons.notifications_active,
      onGrant: onGrant,
      onSkip: onSkip,
    );
  }
}
