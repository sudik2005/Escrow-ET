import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/api_exception.dart';
import '../../models/escrow_contract.dart';
import '../../state/auth_controller.dart';
import '../../state/escrow_controller.dart';
import '../widgets/accent_card.dart';
import '../widgets/app_controls.dart';
import '../widgets/status_chip.dart';
import 'checkout_screen.dart';
import 'qr_verify_screen.dart';
import 'scan_confirm_screen.dart';

class TrackingDetailScreen extends ConsumerStatefulWidget {
  const TrackingDetailScreen({super.key, required this.contract});

  final EscrowContract contract;

  @override
  ConsumerState<TrackingDetailScreen> createState() => _TrackingDetailScreenState();
}

class _TrackingDetailScreenState extends ConsumerState<TrackingDetailScreen> {
  late EscrowContract _contract;
  final _pin = TextEditingController();
  final _reason = TextEditingController();
  var _busy = false;

  static const _steps = [
    ('PENDING_PAYMENT', 'Payment initiated'),
    ('FUNDED', 'Funds locked'),
    ('IN_TRANSIT', 'In transit'),
    ('COMPLETED', 'Released'),
  ];

  @override
  void initState() {
    super.initState();
    _contract = widget.contract;
    Future<void>.microtask(_refresh);
  }

  @override
  void dispose() {
    _pin.dispose();
    _reason.dispose();
    super.dispose();
  }

  String? get _token => ref.read(authControllerProvider).session?.token;

  Future<void> _refresh() async {
    final token = _token;
    if (token == null) {
      return;
    }
    try {
      final latest = await ref.read(escrowApiProvider).getOne(token, _contract.id);
      if (mounted) {
        setState(() => _contract = latest);
        ref.invalidate(escrowListProvider);
      }
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(done)));
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error is ApiException ? error.message : 'Something went wrong.')),
      );
    }
  }

  int get _activeIndex {
    if (_contract.status == 'DISPUTED') {
      return 1;
    }
    final index = _steps.indexWhere((step) => step.$1 == _contract.status);
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).session?.user;
    final seller = user?.isSeller ?? false;
    final buyer = user?.isBuyer ?? false;
    final token = _token;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracking'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    _contract.id.substring(0, 8).toUpperCase(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  StatusChip(contract: _contract),
                  const SizedBox(height: 8),
                  Text('${_contract.amount} ${_contract.currency}'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Status Timeline',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            AccentCard(
              child: Column(
                children: [
                  for (var i = 0; i < _steps.length; i++) ...[
                    _TimelineRow(
                      title: _steps[i].$2,
                      active: i <= _activeIndex && _contract.status != 'DISPUTED',
                      first: i == 0,
                      last: i == _steps.length - 1,
                    ),
                    if (i != _steps.length - 1) const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
            if (buyer && _contract.isPendingPayment) ...[
              const SizedBox(height: 16),
              AppButton(
                label: 'CONFIRM PAYMENT',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => CheckoutScreen(contract: _contract)),
                  );
                },
              ),
            ],
            if (seller && _contract.isFunded) ...[
              const SizedBox(height: 16),
              AppButton(
                label: 'MARK SHIPPED',
                busy: _busy,
                onPressed: token == null
                    ? null
                    : () => _run(
                        () => ref.read(escrowApiProvider).markShipped(token, _contract.id),
                        done: 'Marked in transit.',
                      ),
              ),
            ],
            if (seller && (_contract.isFunded || _contract.isInTransit) && _contract.deliveryQrToken != null) ...[
              const SizedBox(height: 12),
              AppButton(
                label: 'SHOW DELIVERY QR',
                outlined: true,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => QrVerifyScreen(contract: _contract)),
                  );
                },
              ),
            ],
            if (buyer && _contract.canConfirm) ...[
              const SizedBox(height: 16),
              AppTextField(
                controller: _pin,
                label: 'DELIVERY PIN',
                hint: 'PIN from the seller',
                obscureText: true,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'CONFIRM WITH PIN',
                busy: _busy,
                onPressed: () {
                  if (token == null) {
                    return;
                  }
                  final pin = _pin.text.trim();
                  if (pin.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Enter the PIN or scan the QR.')),
                    );
                    return;
                  }
                  _run(
                    () => ref.read(escrowApiProvider).confirmDelivery(
                      token: token,
                      id: _contract.id,
                      pin: pin,
                    ),
                    done: 'Delivery confirmed. Funds released.',
                  );
                },
              ),
              const SizedBox(height: 8),
              AppButton(
                label: 'SCAN QR',
                outlined: true,
                onPressed: () async {
                  if (token == null) {
                    return;
                  }
                  final scanned = await Navigator.of(context).push<String>(
                    MaterialPageRoute(builder: (_) => const ScanConfirmScreen()),
                  );
                  if (scanned == null || scanned.isEmpty) {
                    return;
                  }
                  _run(
                    () => ref.read(escrowApiProvider).confirmDelivery(
                      token: token,
                      id: _contract.id,
                      qrToken: scanned,
                    ),
                    done: 'Delivery confirmed. Funds released.',
                  );
                },
              ),
            ],
            if (_contract.canDispute) ...[
              const SizedBox(height: 16),
              AppTextField(
                controller: _reason,
                label: 'DISPUTE REASON',
                hint: 'At least 5 characters',
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'OPEN DISPUTE',
                outlined: true,
                busy: _busy,
                onPressed: () {
                  if (token == null) {
                    return;
                  }
                  final reason = _reason.text.trim();
                  if (reason.length < 5) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Give a reason of at least 5 characters.')),
                    );
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
          ],
        ),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.title,
    required this.active,
    required this.first,
    required this.last,
  });

  final String title;
  final bool active;
  final bool first;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final color = active
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.outline;
    return Row(
      children: [
        Icon(
          active ? Icons.radio_button_checked : Icons.radio_button_off,
          size: 18,
          color: color,
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: active ? Theme.of(context).colorScheme.onSurface : null,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
