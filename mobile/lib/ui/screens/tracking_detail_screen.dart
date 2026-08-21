import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/api_exception.dart';
import '../../models/escrow_contract.dart';
import '../../state/auth_controller.dart';
import '../../state/escrow_controller.dart';
import '../../theme/app_colors.dart';
import '../widgets/app_controls.dart';
import '../widgets/app_header.dart';
import '../widgets/status_chip.dart';
import 'checkout_screen.dart';
import 'qr_verify_screen.dart';
import 'scan_confirm_screen.dart';

class TrackingDetailScreen extends ConsumerStatefulWidget {
  const TrackingDetailScreen({super.key, required this.contract});

  final EscrowContract contract;

  @override
  ConsumerState<TrackingDetailScreen> createState() =>
      _TrackingDetailScreenState();
}

class _TrackingDetailScreenState
    extends ConsumerState<TrackingDetailScreen> {
  late EscrowContract _contract;
  final _pin = TextEditingController();
  final _reason = TextEditingController();
  var _busy = false;

  static const _steps = [
    ('PENDING_PAYMENT', 'Payment Initiated',
        'Funds debited from buyer account.'),
    ('FUNDED', 'Funds Locked', 'Escrow secured. Awaiting shipment.'),
    ('IN_TRANSIT', 'In Transit', 'Item dispatched to buyer.'),
    ('COMPLETED', 'Destination Reached', 'Funds released to seller.'),
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

  String? get _token =>
      ref.read(authControllerProvider).session?.token;

  Future<void> _refresh() async {
    final token = _token;
    if (token == null) return;
    try {
      final latest = await ref
          .read(escrowApiProvider)
          .getOne(token, _contract.id);
      if (mounted) {
        setState(() => _contract = latest);
        ref.invalidate(escrowListProvider);
      }
    } on ApiException catch (e) {
      if (mounted) _snack(e.message);
    }
  }

  Future<void> _run(
    Future<EscrowContract> Function() action, {
    String? done,
  }) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final latest = await action();
      if (!mounted) return;
      setState(() {
        _contract = latest;
        _busy = false;
      });
      ref.invalidate(escrowListProvider);
      if (done != null) _snack(done);
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      _snack(e is ApiException ? e.message : 'Something went wrong.');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  int get _activeIndex {
    if (_contract.status == 'DISPUTED') return 1;
    final idx =
        _steps.indexWhere((s) => s.$1 == _contract.status);
    return idx < 0 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    final user =
        ref.watch(authControllerProvider).session?.user;
    final seller = user?.isSeller ?? false;
    final buyer = user?.isBuyer ?? false;
    final token = _token;
    final dark = AppColors.isDark(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(
              title: 'Tracking',
              showBack: true,
              showAvatar: true,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  physics:
                      const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                      24, 8, 24, 40),
                  children: [
                    // ── Hero card ──────────────────────
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: dark
                            ? AppColors.darkSurface
                            : AppColors.snow,
                        borderRadius:
                            BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outline,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.crimson
                                  .withValues(alpha: 0.12),
                              borderRadius:
                                  BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.swap_horiz_rounded,
                              color: AppColors.crimson,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            _contract.statusLabel
                                .toUpperCase(),
                            style: GoogleFonts.geist(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.4,
                              color: AppColors.crimson,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_contract.amount} ${_contract.currency}',
                            style: GoogleFonts.geist(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: dark
                                  ? AppColors.darkContainerHigh
                                  : AppColors.lightContainer,
                              borderRadius:
                                  BorderRadius.circular(999),
                            ),
                            child: Text(
                              'ID: #${_contract.id.length >= 8 ? _contract.id.substring(0, 8).toUpperCase() : _contract.id}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Live Tracking timeline ─────────
                    Text(
                      'Live Tracking',
                      style: GoogleFonts.geist(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color:
                            Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: dark
                            ? AppColors.darkSurface
                            : AppColors.snow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outline,
                        ),
                      ),
                      child: Column(
                        children: [
                          for (var i = 0;
                              i < _steps.length;
                              i++) ...[
                            _TimelineStep(
                              title: _steps[i].$2,
                              subtitle: _steps[i].$3,
                              state: i < _activeIndex
                                  ? _StepState.done
                                  : i == _activeIndex
                                      ? _StepState.current
                                      : _StepState.upcoming,
                              isLast: i == _steps.length - 1,
                            ),
                          ],
                        ],
                      ),
                    ),

                    // ── Role-specific CTAs ─────────────
                    if (buyer &&
                        _contract.isPendingPayment) ...[
                      const SizedBox(height: 20),
                      AppButton(
                        label: 'CONFIRM PAYMENT',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CheckoutScreen(
                                  contract: _contract),
                            ),
                          );
                        },
                      ),
                    ],

                    if (seller && _contract.isFunded) ...[
                      const SizedBox(height: 20),
                      AppButton(
                        label: 'MARK SHIPPED',
                        busy: _busy,
                        onPressed: token == null
                            ? null
                            : () => _run(
                                  () => ref
                                      .read(escrowApiProvider)
                                      .markShipped(
                                          token, _contract.id),
                                  done: 'Marked in transit.',
                                ),
                      ),
                    ],

                    if (seller &&
                        (_contract.isFunded ||
                            _contract.isInTransit) &&
                        _contract.deliveryQrToken !=
                            null) ...[
                      const SizedBox(height: 12),
                      AppButton(
                        label: 'SHOW DELIVERY QR',
                        outlined: true,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => QrVerifyScreen(
                                  contract: _contract),
                            ),
                          );
                        },
                      ),
                    ],

                    if (buyer && _contract.canConfirm) ...[
                      const SizedBox(height: 20),
                      AppButton(
                        label: 'SCAN QR TO CONFIRM',
                        busy: _busy,
                        icon: Icons.qr_code_scanner,
                        onPressed: () async {
                          if (token == null) return;
                          final scanned = await Navigator.of(context)
                              .push<String>(
                            MaterialPageRoute(
                              builder: (_) => const ScanConfirmScreen(),
                            ),
                          );
                          if (scanned == null || scanned.isEmpty) {
                            return;
                          }
                          _run(
                            () => ref
                                .read(escrowApiProvider)
                                .confirmDelivery(
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
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _reason,
                        label: 'DISPUTE REASON',
                        hint:
                            'Describe the issue (min 5 chars)',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        label: 'OPEN DISPUTE',
                        outlined: true,
                        busy: _busy,
                        onPressed: () {
                          if (token == null) return;
                          final reason = _reason.text.trim();
                          if (reason.length < 5) {
                            _snack(
                                'Give a reason of at least 5 characters.');
                            return;
                          }
                          _run(
                            () => ref
                                .read(escrowApiProvider)
                                .openDispute(
                                  token: token,
                                  id: _contract.id,
                                  reason: reason,
                                ),
                            done: 'Dispute opened.',
                          );
                        },
                      ),
                    ],

                    const SizedBox(height: 16),
                    // Status chip bottom
                    Center(child: StatusChip(contract: _contract)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Timeline step ─────────────────────────────────────────────────────────────
enum _StepState { done, current, upcoming }

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.title,
    required this.subtitle,
    required this.state,
    required this.isLast,
  });

  final String title;
  final String subtitle;
  final _StepState state;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);
    final isDone = state == _StepState.done;
    final isCurrent = state == _StepState.current;
    final isUpcoming = state == _StepState.upcoming;

    final dotColor = isUpcoming
        ? (dark ? AppColors.darkContainerHigh : AppColors.lightContainer)
        : AppColors.crimson;
    final lineColor = isDone
        ? AppColors.crimson
        : (dark ? AppColors.darkContainerHigh : AppColors.lightContainer);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Dot + line column ──────────────────────
          SizedBox(
            width: 24,
            child: Column(
              children: [
                // dot
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    border: isUpcoming
                        ? Border.all(
                            color: dark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                            width: 2,
                          )
                        : null,
                  ),
                  child: isDone
                      ? const Icon(Icons.check,
                          color: AppColors.snow, size: 13)
                      : null,
                ),
                // line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: lineColor,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          // ── Text ──────────────────────────────────
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.geist(
                      fontSize: 14,
                      fontWeight: isCurrent || isDone
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: isUpcoming
                          ? Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.4)
                          : isCurrent
                              ? AppColors.crimson
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                          color: isUpcoming
                              ? Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.3)
                              : null,
                          height: 1.4,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
