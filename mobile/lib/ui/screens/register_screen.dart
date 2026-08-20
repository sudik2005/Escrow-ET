import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/auth_controller.dart';
import '../../theme/app_colors.dart';
import '../widgets/app_controls.dart';
import '../widgets/icon_field.dart';
import '../widgets/matrix_backdrop.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _username = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  var _role = 'BUYER';
  var _hidePassword = true;
  var _accepted = false;
  String? _localError;

  @override
  void dispose() {
    _username.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final username = _username.text.trim();
    final phone = _phone.text.trim();
    final password = _password.text;
    if (username.isEmpty || phone.isEmpty) {
      setState(() => _localError = 'Designation and phone uplink are required.');
      return;
    }
    if (password.length < 8) {
      setState(() => _localError = 'Security key must be at least 8 characters.');
      return;
    }
    if (password != _confirm.text) {
      setState(() => _localError = 'Security keys do not match.');
      return;
    }
    if (!_accepted) {
      setState(() => _localError = 'Accept the protocols to continue.');
      return;
    }
    setState(() => _localError = null);
    await ref.read(authControllerProvider.notifier).register(
      username: username,
      password: password,
      phoneNumber: phone,
      role: _role,
      email: _email.text.trim(),
    );
    if (mounted && ref.read(authControllerProvider).status == AuthStatus.signedIn) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final dark = AppColors.isDark(context);
    final error = auth.error ?? _localError;

    return Scaffold(
      body: MatrixBackdrop(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: dark ? AppColors.darkContainerHigh : AppColors.lightContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.auto_awesome,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    dark ? 'Initialize Access' : 'Establish Node',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dark
                        ? 'Establish your secure node within the network. Enter credentials to proceed.'
                        : 'Initialize your credentials to access the high-performance Crimson Matrix dashboard.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 28),
                  AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        IconField(
                          controller: _username,
                          icon: Icons.badge_outlined,
                          label: 'DESIGNATION (FULL NAME)',
                          hint: 'Jane Doe',
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.username],
                        ),
                        const SizedBox(height: 16),
                        IconField(
                          controller: _phone,
                          icon: Icons.phone_outlined,
                          label: 'UPLINK (PHONE)',
                          hint: '+2519...',
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.telephoneNumber],
                        ),
                        const SizedBox(height: 16),
                        IconField(
                          controller: _email,
                          icon: Icons.alternate_email,
                          label: 'UPLINK (EMAIL)',
                          hint: 'jane.doe@matrix.net',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'NODE TYPE',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            letterSpacing: 0.8,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            for (final role in const [('BUYER', 'Buyer'), ('SELLER', 'Seller')])
                              ChoiceChip(
                                label: Text(role.$2),
                                selected: _role == role.$1,
                                onSelected: (_) => setState(() => _role = role.$1),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        IconField(
                          controller: _password,
                          icon: Icons.lock_outline,
                          label: 'CIPHER (PASSWORD)',
                          hint: '••••••••',
                          obscureText: _hidePassword,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.newPassword],
                          suffix: IconButton(
                            onPressed: () => setState(() => _hidePassword = !_hidePassword),
                            icon: Icon(
                              _hidePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        IconField(
                          controller: _confirm,
                          icon: Icons.verified_user_outlined,
                          label: 'VERIFY CIPHER',
                          hint: '••••••••',
                          obscureText: _hidePassword,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _submit(),
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: () => setState(() => _accepted = !_accepted),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: _accepted,
                                onChanged: (value) => setState(() => _accepted = value ?? false),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Text(
                                    'I acknowledge and accept the Terms of Protocol and Data Privacy Directive.',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (error != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            error,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        AppButton(
                          label: dark ? 'EXECUTE GENESIS' : 'CREATE ACCOUNT',
                          icon: Icons.arrow_forward,
                          busy: auth.busy,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: 24),
                        TextButton(
                          onPressed: auth.busy ? null : () => Navigator.of(context).pop(),
                          child: const Text('ACTIVE OPERATIVE? AUTHENTICATE HERE'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
