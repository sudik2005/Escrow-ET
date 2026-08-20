import 'package:flutter/material.dart';

import '../../models/escrow_contract.dart';
import '../widgets/accent_card.dart';
import '../widgets/app_controls.dart';
import '../widgets/app_header.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key, required this.contract});

  final EscrowContract contract;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          children: [
            const AppHeader(title: 'Payments'),
            const SizedBox(height: 24),
            Center(
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                ),
                child: Icon(
                  Icons.check,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '${contract.amount} ${contract.currency}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Payment Successful',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            AccentCard(
              stripe: true,
              child: Column(
                children: [
                  _Row(label: 'REFERENCE', value: contract.id.substring(0, 8).toUpperCase()),
                  const Divider(),
                  _Row(label: 'ITEM', value: contract.itemName),
                  const Divider(),
                  _Row(label: 'STATUS', value: contract.statusLabel),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'DONE',
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 0.8)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
