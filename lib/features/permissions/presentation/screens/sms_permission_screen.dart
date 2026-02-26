import 'package:flutter/material.dart';
import '../widgets/permission_screen.dart';

class SMSPermissionScreen extends StatelessWidget {
  final VoidCallback onGrant;
  final VoidCallback onSkip;

  const SMSPermissionScreen({
    super.key,
    required this.onGrant,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return PermissionScreen(
      title: 'Enable SMS Access',
      description: 'We request access to your SMS to provide better service. '
          'Your messages are private and will only be used to improve your experience.',
      icon: Icons.sms,
      onGrant: onGrant,
      onSkip: onSkip,
    );
  }
}
