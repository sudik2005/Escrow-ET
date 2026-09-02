import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/api_exception.dart';
import '../../data/phone.dart';
import '../../state/auth_controller.dart';
import '../../state/escrow_controller.dart';
import '../../theme/app_colors.dart';
import '../widgets/app_controls.dart';
import '../widgets/app_header.dart';

class NewPaymentScreen extends ConsumerStatefulWidget {
  const NewPaymentScreen({super.key});

  @override
  ConsumerState<NewPaymentScreen> createState() => _NewPaymentScreenState();
}

class _NewPaymentScreenState extends ConsumerState<NewPaymentScreen> {
  final _amount = TextEditingController();
  final _item = TextEditingController();
  final _phone = TextEditingController();
  var _busy = false;
  String? _error;

  static String _generatePin() {
    final rng = Random.secure();
    return List.generate(8, (_) => rng.nextInt(10)).join();
  }

  @override
  void dispose() {
    _amount.dispose();
    _item.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final token = ref.read(authControllerProvider).session?.token;
    final amount = _amount.text.trim();
    final item = _item.text.trim();
    final phone = _phone.text.trim();

    if (token == null || amount.isEmpty || item.isEmpty || phone.isEmpty) {
      setState(() => _error = 'Amount, product, and buyer phone are required.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final pin = _generatePin();
      final contract = await ref.read(escrowApiProvider).create(
            token: token,
            buyerPhone: normalizeEtPhone(phone),
            itemName: item,
            amount: amount,
            pin: pin,
          );
      await ref.read(sessionStoreProvider).savePin(contract.id, pin);
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted) setState(() { _busy = false; _error = e.message; });
    } catch (_) {
      if (mounted) setState(() { _busy = false; _error = 'Something went wrong. Try again.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Payments', showBack: true, showAvatar: false),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                children: [
                  // ── Hero icon + title ─────────────────
                  const SizedBox(height: 20),
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.crimson.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.link,
                        color: AppColors.crimson,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Payment Link',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.geist(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Create a shareable link to collect ETB securely.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: dark ? AppColors.darkMuted : AppColors.lightMuted,
                        ),
                  ),
                  const SizedBox(height: 32),

                  // ── Amount hero card ──────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    decoration: BoxDecoration(
                      color: dark ? AppColors.darkSurface : AppColors.snow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).colorScheme.outline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AMOUNT TO COLLECT',
                          style: GoogleFonts.geist(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'ETB',
                              style: GoogleFonts.geist(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.crimson,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _amount,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                textInputAction: TextInputAction.next,
                                style: GoogleFonts.geist(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35),
                                ),
                                decoration: InputDecoration(
                                  hintText: '0.00',
                                  hintStyle: GoogleFonts.geist(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25),
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  filled: false,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Fields ────────────────────────────
                  AppTextField(
                    controller: _item,
                    label: 'PRODUCT OR SERVICE NAME',
                    hint: 'e.g. Graphic Design Retainer',
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: _phone,
                    label: 'BUYER PHONE',
                    hint: '+2519...',
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                  ),

                  if (_error != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      _error!,
                      style: TextStyle(
                        color: AppColors.crimson,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],

                  const SizedBox(height: 28),
                  AppButton(
                    label: 'GENERATE LINK  →',
                    busy: _busy,
                    onPressed: _submit,
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
