import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/api_exception.dart';
import '../../models/escrow_contract.dart';
import '../../state/auth_controller.dart';
import '../../state/escrow_controller.dart';
import '../../theme/app_colors.dart';
import '../widgets/accent_card.dart';
import '../widgets/app_controls.dart';
import '../widgets/app_header.dart';
import '../widgets/status_chip.dart';
import 'payment_success_screen.dart';

// Chapa cannot deep-link back; poll until the webhook funds the contract.
const _pollInterval = Duration(seconds: 4);
const _pollTimeout = Duration(minutes: 4);

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key, required this.contract});

  final EscrowContract contract;

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen>
    with WidgetsBindingObserver {
  late EscrowContract _contract;
  var _busy = false;
  var _checking = false;
  var _awaitingPayment = false;
  var _timedOut = false;
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    _contract = widget.contract;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _poll?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _awaitingPayment) {
      _checkStatus();
    }
  }

  String? get _token => ref.read(authControllerProvider).session?.token;

  Future<void> _openChapa() async {
    final token = _token;
    if (token == null || _busy) return;
    setState(() => _busy = true);
    try {
      var link = _contract.paymentLink;
      link ??= await ref.read(escrowApiProvider).pay(token, _contract.id);
      final uri = Uri.tryParse(link);
      if (uri == null) throw const ApiException('Payment link is not valid.');
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (mounted) {
        setState(() {
          _contract = _contract.copyWith(paymentLink: link);
          _busy = false;
        });
        _startWatching();
      }
    } catch (error) {
      if (mounted) {
        setState(() => _busy = false);
        _snack(error is ApiException ? error.message : 'Could not open Chapa.');
      }
    }
  }

  void _startWatching() {
    _poll?.cancel();
    setState(() {
      _awaitingPayment = true;
      _timedOut = false;
    });
    final startedAt = DateTime.now();
    _poll = Timer.periodic(_pollInterval, (timer) {
      if (DateTime.now().difference(startedAt) > _pollTimeout) {
        timer.cancel();
        if (mounted) setState(() => _timedOut = true);
        return;
      }
      _checkStatus();
    });
  }

  Future<void> _checkStatus({bool announce = false}) async {
    final token = _token;
    if (token == null || _checking) return;
    setState(() => _checking = true);
    try {
      final latest =
          await ref.read(escrowApiProvider).getOne(token, _contract.id);
      if (!mounted) return;
      if (latest.isPendingPayment) {
        setState(() {
          _contract = latest;
          _checking = false;
        });
        if (announce) _snack('Chapa has not confirmed the payment yet.');
        return;
      }
      _poll?.cancel();
      ref.invalidate(escrowListProvider);
      await ref.read(authControllerProvider.notifier).refreshUser();
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (_) => PaymentSuccessScreen(contract: latest)),
      );
    } catch (error) {
      if (mounted) {
        setState(() => _checking = false);
        if (announce) {
          _snack(error is ApiException
              ? error.message
              : 'Could not check the payment.');
        }
      }
    }
  }

  Future<void> _sandboxFund() async {
    final token = _token;
    if (token == null || _busy) return;
    setState(() => _busy = true);
    try {
      final latest =
          await ref.read(escrowApiProvider).sandboxFund(token, _contract.id);
      ref.invalidate(escrowListProvider);
      await ref.read(authControllerProvider.notifier).refreshUser();
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (_) => PaymentSuccessScreen(contract: latest)),
      );
    } catch (error) {
      if (mounted) {
        setState(() => _busy = false);
        _snack(error is ApiException ? error.message : 'Could not mark paid.');
      }
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: 'Payments', showBack: true, showAvatar: false),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                children: [
                  // ── Order Details card ─────────────────
                  _SectionLabel('ORDER DETAILS'),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: dark ? AppColors.darkSurface : AppColors.snow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Theme.of(context).colorScheme.outline),
                    ),
                    child: Column(
                      children: [
                        _ItemRow(
                          icon: Icons.inventory_2_outlined,
                          name: _contract.itemName,
                          detail:
                              '${_contract.sellerPhone} · Escrow',
                          amount:
                              '${_contract.amount} ${_contract.currency}',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Cost breakdown ─────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: dark ? AppColors.darkSurface : AppColors.snow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Theme.of(context).colorScheme.outline),
                    ),
                    child: Column(
                      children: [
                        _CostRow(
                          label: 'Subtotal',
                          value: '${_contract.amount} ${_contract.currency}',
                          muted: true,
                        ),
                        const SizedBox(height: 8),
                        _CostRow(
                          label: 'Escrow fee',
                          value: '0.00 ${_contract.currency}',
                          muted: true,
                        ),
                        const SizedBox(height: 12),
                        Divider(
                            color: Theme.of(context).colorScheme.outline),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              'Total',
                              style: GoogleFonts.geist(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${_contract.amount} ${_contract.currency}',
                              style: GoogleFonts.geist(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.crimson,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ── Status + chip ──────────────────────
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Contract status:',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 8),
                      StatusChip(contract: _contract),
                    ],
                  ),

                  // ── Awaiting banner ────────────────────
                  if (_awaitingPayment) ...[
                    const SizedBox(height: 16),
                    AccentCard(
                      alert: true,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!_timedOut)
                            const Padding(
                              padding: EdgeInsets.only(top: 2, right: 12),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.crimson),
                              ),
                            ),
                          Expanded(
                            child: Text(
                              _timedOut
                                  ? 'Still no confirmation from Chapa. Complete payment in your browser, then tap check below.'
                                  : 'Waiting for Chapa to confirm your payment. Keep this screen open.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // ── Primary CTA — Chapa (app-colored) ──
                  _ChapaButton(
                    label: _awaitingPayment
                        ? 'REOPEN CHAPA  →'
                        : 'CONTINUE TO PAYMENT  →',
                    busy: _busy,
                    onPressed: _openChapa,
                  ),

                  if (_awaitingPayment) ...[
                    const SizedBox(height: 10),
                    AppButton(
                      label: 'I HAVE PAID — CHECK NOW',
                      outlined: true,
                      busy: _checking,
                      onPressed: () => _checkStatus(announce: true),
                    ),
                  ],

                  // ── Sandbox bypass ─────────────────────
                  const SizedBox(height: 10),
                  AppButton(
                    label: 'SANDBOX — SIMULATE PAYMENT',
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

// ── Chapa primary button — all app colors, no Chapa green ────────────────────
class _ChapaButton extends StatelessWidget {
  const _ChapaButton({
    required this.label,
    required this.busy,
    required this.onPressed,
  });

  final String label;
  final bool busy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 56,
          child: FilledButton(
            onPressed: busy ? null : onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.crimson,
              foregroundColor: AppColors.snow,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.snow),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.account_balance_wallet_outlined,
                          size: 18),
                      const SizedBox(width: 10),
                      Text(
                        label,
                        style: GoogleFonts.geist(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Powered by Chapa · Secure payment',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.4),
              ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.geist(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({
    required this.icon,
    required this.name,
    required this.detail,
    required this.amount,
  });

  final IconData icon;
  final String name;
  final String detail;
  final String amount;

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: dark ? AppColors.darkContainerHigh : AppColors.lightContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon,
                size: 22,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(detail,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Text(
            amount,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _CostRow extends StatelessWidget {
  const _CostRow({
    required this.label,
    required this.value,
    this.muted = false,
  });

  final String label;
  final String value;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final color = muted
        ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55)
        : Theme.of(context).colorScheme.onSurface;
    return Row(
      children: [
        Text(label, style: TextStyle(color: color, fontSize: 14)),
        const Spacer(),
        Text(value, style: TextStyle(color: color, fontSize: 14)),
      ],
    );
  }
}
