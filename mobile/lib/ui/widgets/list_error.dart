import 'package:flutter/material.dart';

import 'accent_card.dart';
import 'app_controls.dart';

class ListError extends StatelessWidget {
  const ListError({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      children: [
        AccentCard(
          alert: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(message, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              AppButton(label: 'TRY AGAIN', outlined: true, onPressed: onRetry),
            ],
          ),
        ),
      ],
    );
  }
}
