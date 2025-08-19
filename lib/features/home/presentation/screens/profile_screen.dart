import 'package:dhanra/core/services/local_storage_service.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback onLogout;

  const ProfileScreen({
    Key? key,
    required this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final storage = LocalStorageService();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
              const SizedBox(height: 20),
              Text(
                storage.userName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              Text(
                storage.userPhone,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: onLogout,
                child: const Text('Logout'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
