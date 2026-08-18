import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/auth_controller.dart';
import '../widgets/app_controls.dart';
import '../widgets/auth_scaffold.dart';

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
  String _role = 'BUYER';
  bool _hidePassword = true;

  @override
  void dispose() {
    _username.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final username = _username.text.trim();
    final phone = _phone.text.trim();
    final password = _password.text;
    if (username.isEmpty || phone.isEmpty || password.length < 8) {
      return;
    }
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

    return AuthScaffold(
      eyebrow: 'New account',
      title: 'Create account',
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: _username,
              label: 'Username',
              hint: 'Choose a username',
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.username],
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _phone,
              label: 'Phone number',
              hint: '+2519...',
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.telephoneNumber],
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _email,
              label: 'Email (optional)',
              hint: 'you@email.com',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
            ),
            const SizedBox(height: 16),
            Text(
              'I am a',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final role in const [
                  ('BUYER', 'Buyer'),
                  ('SELLER', 'Seller'),
                ])
                  ChoiceChip(
                    label: Text(role.$2),
                    selected: _role == role.$1,
                    onSelected: (_) => setState(() => _role = role.$1),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _password,
              label: 'Password',
              hint: 'At least 8 characters',
              obscureText: _hidePassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              onSubmitted: (_) => _submit(),
              suffix: IconButton(
                onPressed: () => setState(() => _hidePassword = !_hidePassword),
                icon: Icon(
                  _hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                ),
              ),
            ),
            if (auth.error != null) ...[
              const SizedBox(height: 16),
              Text(
                auth.error!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 24),
            AppButton(
              label: 'Create account',
              busy: auth.busy,
              onPressed: _submit,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: auth.busy ? null : () => Navigator.of(context).pop(),
              child: const Text('Already have an account? Sign in'),
            ),
          ],
        ),
      ),
    );
  }
}
