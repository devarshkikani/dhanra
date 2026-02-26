import 'package:flutter/material.dart';
import '../widgets/permission_screen.dart';

class LocationPermissionScreen extends StatelessWidget {
  final VoidCallback onGrant;
  final VoidCallback onSkip;

  const LocationPermissionScreen({
    super.key,
    required this.onGrant,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return PermissionScreen(
      title: 'Enable Location',
      description:
          'We request access to your Location to provide personalized recommendations. '
          'Your location data is secure and will only be used to enhance your experience.',
      icon: Icons.location_on,
      onGrant: onGrant,
      onSkip: onSkip,
    );
  }
}
