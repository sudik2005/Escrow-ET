import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/api_exception.dart';
import '../../models/escrow_contract.dart';
import '../../models/user.dart';
import '../../state/auth_controller.dart';
import '../../state/escrow_controller.dart';
import '../../theme/app_colors.dart';
import '../widgets/app_controls.dart';
import '../widgets/brand_card.dart';

class EscrowDetailScreen extends ConsumerStatefulWidget {
  const EscrowDetailScreen({super.key, required this.contract});

  final EscrowContract contract;

  @override
  ConsumerState<EscrowDetailScreen> createState() => _EscrowDetailScreenState();
}

class _EscrowDetailScreenState extends ConsumerState<EscrowDetailScreen> {
  late EscrowContract _contract;
  final _pin = TextEditingController();
  final _qrToken = TextEditingController();
  final _reason = TextEditingController();
  var _busy = false;

  @override
  void initState() {
    super.initState();
    _contract = widget.contract;
    Future<void>.microtask(_refresh);
  }

  @override
  void dispose() {
    _pin.dispose();
    _qrToken.dispose();
    _reason.dispose();
    super.dispose();
  }

  String? get _token => ref.read(authControllerProvider).session?.token;
  User? get _user => ref.read(authControllerProvider).session?.user;

  Future<void> _refresh() async {
    final token = _token;
    if (token == null) {
      return;
    }
    try {
      final latest = await ref.read(escrowApiProvider).getOne(token, _contract.id);
      if (!mounted) {
        return;
      }
      setState(() => _contract = latest);
      ref.invalidate(escrowListProvider);
    } on ApiException catch (error) {
      if (mounted) {
        showAppError(context, error);
      }
    }
  }

  Future<void> _run(Future<EscrowContract> Function() action, {String? done}) async {
    if (_busy) {
      return;
    }
    setState(() => _busy = true);
    try {
      final latest = await action();
      if (!mounted) {
        return;
      }
      setState(() {
        _contract = latest;
        _busy = false;
      });
      ref.invalidate(escrowListProvider);
      if (done != null) {
        showAppMessage(context, done);
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _busy = false);
      showAppError(context, error);
    }
  }

  Future<void> _pay() async {
    final token = _token;
    if (token == null || _busy) {
      return;
    }
    setState(() => _busy = true);
    try {
      var link = _contract.paymentLink;
      if (link == null) {
        link = await ref.read(escrowApiProvider).pay(token, _contract.id);
        if (mounted) {
          setState(() => _contract = _contract.copyWith(paymentLink: link));
        }
      }
      final uri = Uri.tryParse(link);
      if (uri == null) {
        throw const ApiException('Payment link is not valid.');
      }
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!mounted) {
        return;
      }
      setState(() => _busy = false);
      if (!opened) {
        showAppMessage(context, 'Could not open the payment page.');
        return;
      }
      showAppMessage(
        context,
        'Finish payment in the browser, then pull to refresh this screen.',
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _busy = false);
      showAppError(context, error);
    }
  }

  Future<void> _copyToken() async {
    final token = _contract.deliveryQrToken;
    if (token == null) {
      return;
    }
    await Clipboard.setData(ClipboardData(text: token));
    if (mounted) {
      showAppMessage(context, 'Delivery token copied.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.darkText : AppColors.lightText;
    final seller = user?.isSeller ?? false;
    final buyer = user?.isBuyer ?? false;
    final showQr =
        seller &&
        _contract.deliveryQrToken != null &&
        (_contract.isFunded || _contract.isInTransit || _contract.status == 'DELIVERED_UNVERIFIED');

    return Scaffold(
      appBar: AppBar(title: Text(_contract.itemName)),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: [
            BrandCard(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _contract.statusLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_contract.amount} ${_contract.currency}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Buyer  ${_contract.buyerPhone}', style: TextStyle(color: muted)),
                    const SizedBox(height: 4),
                    Text('Seller  ${_contract.sellerPhone}', style: TextStyle(color: muted)),
                  ],
                ),
              ),
            ),
            if (showQr) ...[
              const SizedBox(height: 16),
              BrandCard(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
                  child: Column(
                    children: [
                      Text(
                        'Show this QR at delivery. The buyer scans or pastes the token.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                      ),
                      const SizedBox(height: 16),
                      ColoredBox(
                        color: Colors.white,
                        child: QrImageView(
                          data: _contract.deliveryQrToken!,
                          size: 220,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _copyToken,
                        child: const Text('Copy delivery token'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (seller && _contract.isFunded) ...[
              const SizedBox(height: 16),
              AppButton(
                label: 'Mark shipped',
                busy: _busy,
                onPressed: () {
                  final token = _token;
                  if (token == null) {
                    return;
                  }
                  _run(
                    () => ref.read(escrowApiProvider).markShipped(token, _contract.id),
                    done: 'Marked as in transit.',
                  );
                },
              ),
            ],
            if (buyer && _contract.isPendingPayment) ...[
              const SizedBox(height: 16),
              AppButton(label: 'Pay with Chapa', busy: _busy, onPressed: _pay),
            ],
            if (buyer && _contract.canConfirm) ...[
              const SizedBox(height: 16),
              BrandCard(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Confirm delivery',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter the seller’s PIN or paste the delivery token from their QR.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                      ),
                      if (_contract.pinIsSet) ...[
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _pin,
                          label: 'Delivery PIN',
                          hint: 'PIN from the seller',
                          obscureText: true,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                        ),
                      ],
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _qrToken,
                        label: 'QR token (optional)',
                        hint: 'Paste the delivery token',
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 20),
                      AppButton(
                        label: 'Confirm delivery',
                        busy: _busy,
                        onPressed: () {
                          final token = _token;
                          final pin = _pin.text.trim();
                          final qr = _qrToken.text.trim();
                          if (token == null) {
                            return;
                          }
                          if (pin.isEmpty && qr.isEmpty) {
                            showAppMessage(context, 'Enter a PIN or paste the QR token.');
                            return;
                          }
                          _run(
                            () => ref.read(escrowApiProvider).confirmDelivery(
                              token: token,
                              id: _contract.id,
                              pin: pin,
                              qrToken: qr,
                            ),
                            done: 'Delivery confirmed. Funds released.',
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (_contract.canDispute) ...[
              const SizedBox(height: 16),
              BrandCard(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Dispute',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _reason,
                        label: 'Reason',
                        hint: 'At least 5 characters',
                        maxLines: 4,
                        textInputAction: TextInputAction.newline,
                      ),
                      const SizedBox(height: 20),
                      AppButton(
                        label: 'Open dispute',
                        outlined: true,
                        busy: _busy,
                        onPressed: () {
                          final token = _token;
                          final reason = _reason.text.trim();
                          if (token == null) {
                            return;
                          }
                          if (reason.length < 5) {
                            showAppMessage(context, 'Give a reason of at least 5 characters.');
                            return;
                          }
                          _run(
                            () => ref.read(escrowApiProvider).openDispute(
                              token: token,
                              id: _contract.id,
                              reason: reason,
                            ),
                            done: 'Dispute opened.',
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
