import 'package:flutter/material.dart';

class PermissionDialog extends StatelessWidget {
  final VoidCallback onOpenSettings;

  const PermissionDialog({
    Key? key,
    required this.onOpenSettings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Permissions Required'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This feature requires access to Notifications, Location, and SMS.',
          ),
          SizedBox(height: 16),
          Text(
            'To enable permissions:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('1. Go to Settings'),
          Text('2. Tap Privacy'),
          Text('3. Select the permission type'),
          Text('4. Enable the permission'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onOpenSettings();
          },
          child: const Text('Open Settings'),
        ),
      ],
    );
  }
}
