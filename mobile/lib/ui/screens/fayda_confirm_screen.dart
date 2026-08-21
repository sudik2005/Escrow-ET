import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/phone.dart';
import '../../fayda/fayda_decoder.dart';
import '../../state/auth_controller.dart';
import '../../theme/app_colors.dart';
import '../widgets/icon_field.dart';

class FaydaConfirmScreen extends ConsumerStatefulWidget {
  const FaydaConfirmScreen({super.key, required this.fayda});

  final FaydaSuccess fayda;

  @override
  ConsumerState<FaydaConfirmScreen> createState() => _FaydaConfirmScreenState();
}

class _FaydaConfirmScreenState extends ConsumerState<FaydaConfirmScreen> {
  final _phone = TextEditingController();
  var _role = 'BUYER';
  String? _localError;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final phone = _phone.text.trim();
    if (phone.isEmpty) {
      setState(() => _localError = 'Phone number is required.');
      return;
    }
    setState(() => _localError = null);
    await ref.read(authControllerProvider.notifier).registerWithFayda(
          rawPayload: widget.fayda.rawPayload,
          phoneNumber: normalizeEtPhone(phone),
          role: _role,
        );
  }

  Uint8List? get _faceBytes {
    final face = widget.fayda.faceBytes;
    if (face == null || face.isEmpty) return null;
    return face is Uint8List ? face : Uint8List.fromList(face);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final dark = AppColors.isDark(context);
    final error = auth.error ?? _localError;
    final fayda = widget.fayda;
    final face = _faceBytes;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 40),
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: auth.busy
                          ? null
                          : () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Text(
                      'Confirm identity',
                      style: GoogleFonts.geist(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: dark ? AppColors.darkSurface : AppColors.snow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  child: Column(
                    children: [
                      if (face != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            face,
                            width: 88,
                            height: 88,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: AppColors.crimson,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.badge_outlined,
                            color: AppColors.snow,
                            size: 36,
                          ),
                        ),
                      const SizedBox(height: 14),
                      _ReadonlyRow(label: 'Name', value: fayda.fullName),
                      _ReadonlyRow(label: 'Gender', value: fayda.genderLabel),
                      _ReadonlyRow(
                        label: 'Fayda number',
                        value: fayda.fan ?? '—',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'These fields come from your Fayda card and cannot be edited.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: dark
                            ? AppColors.darkMuted
                            : AppColors.lightMuted,
                      ),
                ),
                const SizedBox(height: 28),
                Text(
                  'I AM A',
                  style: GoogleFonts.geist(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _RoleChip(
                        label: 'BUYER',
                        selected: _role == 'BUYER',
                        onTap: () => setState(() => _role = 'BUYER'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RoleChip(
                        label: 'SELLER',
                        selected: _role == 'SELLER',
                        onTap: () => setState(() => _role = 'SELLER'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                IconField(
                  controller: _phone,
                  icon: Icons.phone_outlined,
                  hint: '+2519...',
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  onSubmitted: (_) {
                    if (!auth.busy) _submit();
                  },
                ),
                if (error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    error,
                    style: const TextStyle(
                      color: AppColors.crimson,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: auth.busy ? null : _submit,
                    child: auth.busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.snow,
                            ),
                          )
                        : Text(
                            'CREATE ACCOUNT',
                            style: GoogleFonts.geist(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.4,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReadonlyRow extends StatelessWidget {
  const _ReadonlyRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 46,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.crimson
              : (dark ? AppColors.darkSurface : AppColors.snow),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? AppColors.crimson
                : Theme.of(context).colorScheme.outline,
            width: selected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.geist(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: selected
                  ? AppColors.snow
                  : Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
    );
  }
}
