import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/api_exception.dart';
import '../../models/escrow_contract.dart';
import '../../state/auth_controller.dart';
import '../../state/escrow_controller.dart';
import '../widgets/accent_card.dart';
import '../widgets/app_controls.dart';
import '../widgets/app_header.dart';
import '../widgets/status_chip.dart';
import 'payment_success_screen.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key, required this.contract});

  final EscrowContract contract;

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  late EscrowContract _contract;
  var _busy = false;

  @override
  void initState() {
    super.initState();
    _contract = widget.contract;
  }

  String? get _token => ref.read(authControllerProvider).session?.token;

  Future<void> _openChapa() async {
    final token = _token;
    if (token == null || _busy) {
      return;
    }
    setState(() => _busy = true);
    try {
      var link = _contract.paymentLink;
      link ??= await ref.read(escrowApiProvider).pay(token, _contract.id);
      final uri = Uri.tryParse(link);
      if (uri == null) {
        throw const ApiException('Payment link is not valid.');
      }
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (mounted) {
        setState(() {
          _contract = _contract.copyWith(paymentLink: link);
          _busy = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error is ApiException ? error.message : 'Could not open Chapa.')),
        );
      }
    }
  }

  Future<void> _sandboxFund() async {
    final token = _token;
    if (token == null || _busy) {
      return;
    }
    setState(() => _busy = true);
    try {
      final latest = await ref.read(escrowApiProvider).sandboxFund(token, _contract.id);
      ref.invalidate(escrowListProvider);
      await ref.read(authControllerProvider.notifier).refreshUser();
      if (!mounted) {
        return;
      }
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => PaymentSuccessScreen(contract: latest)),
      );
    } catch (error) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error is ApiException ? error.message : 'Could not mark paid.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 32),
          children: [
            const AppHeader(title: 'Payments'),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AccentCard(
                    stripe: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Order Summary',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            StatusChip(contract: _contract),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: Text(_contract.itemName)),
                            Text(
                              '${_contract.amount} ${_contract.currency}',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  AccentCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Method',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.account_balance_wallet_outlined, color: Theme.of(context).colorScheme.secondary),
                            const SizedBox(width: 12),
                            const Expanded(child: Text('Chapa (sandbox)')),
                            Icon(Icons.radio_button_checked, color: Theme.of(context).colorScheme.secondary),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text('Total', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                      const Spacer(),
                      Text(
                        '${_contract.amount} ${_contract.currency}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    label: 'CONFIRM PAYMENT  →',
                    busy: _busy,
                    onPressed: _openChapa,
                  ),
                  const SizedBox(height: 10),
                  AppButton(
                    label: 'I PAID (SANDBOX)',
                    outlined: true,
                    busy: _busy,
                    onPressed: _sandboxFund,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
