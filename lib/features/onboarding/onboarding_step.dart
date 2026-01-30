import 'package:flutter/material.dart';

class OnboardingStep extends StatelessWidget {
  final String image;
  final String title;
  final String description;

  const OnboardingStep({
    super.key,
    required this.image,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          description,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
      ],
    );
  }
}
