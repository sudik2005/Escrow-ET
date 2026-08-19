import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../models/escrow_contract.dart';
import '../../theme/app_colors.dart';
import '../widgets/accent_card.dart';
import '../widgets/app_controls.dart';

class QrVerifyScreen extends StatelessWidget {
  const QrVerifyScreen({super.key, required this.contract});

  final EscrowContract contract;

  @override
  Widget build(BuildContext context) {
    final token = contract.deliveryQrToken ?? '';
    final dark = AppColors.isDark(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Detail'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        children: [
          Text(
            'Scan to verify',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Present this code at delivery so the buyer can confirm.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.snow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.35)),
              ),
              child: token.isEmpty
                  ? const SizedBox(height: 200, width: 200)
                  : QrImageView(
                      data: token,
                      size: 220,
                      backgroundColor: AppColors.snow,
                    ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: token.isEmpty
                ? null
                : () async {
                    await Clipboard.setData(ClipboardData(text: token));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Delivery token copied.')),
                      );
                    }
                  },
            child: const Text('Copy delivery token'),
          ),
          const SizedBox(height: 16),
          AccentCard(
            alert: true,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'SECURITY WARNING\nDo not share this code except at delivery. It is unique to this escrow.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: dark ? AppColors.darkPrimary : AppColors.lightPrimary,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AppButton(label: 'DONE', onPressed: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }
}
