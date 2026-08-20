import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/auth_controller.dart';
import '../../theme/app_colors.dart';
import '../widgets/app_controls.dart';
import '../widgets/icon_field.dart';
import '../widgets/matrix_backdrop.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  var _hidePassword = true;
  var _rememberMe = false;
  String? _localError;

  @override
  void initState() {
    super.initState();
    final remembered = ref.read(sessionStoreProvider).rememberedUsername();
    if (remembered != null && remembered.isNotEmpty) {
      _username.text = remembered;
      _rememberMe = true;
    }
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final username = _username.text.trim();
    final password = _password.text;
    if (username.isEmpty || password.isEmpty) {
      setState(() => _localError = 'Operator ID and security key are required.');
      return;
    }
    setState(() => _localError = null);
    final store = ref.read(sessionStoreProvider);
    await store.setRememberedUsername(_rememberMe ? username : null);
    await ref.read(authControllerProvider.notifier).login(
      username: username,
      password: password,
    );
  }

  void _openRegister() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const RegisterScreen()),
    );
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
                padding: EdgeInsets.fromLTRB(24, dark ? 48 : 64, 24, 32),
                children: [
                  if (dark) _DarkHeader() else const _LightHeader(),
                  SizedBox(height: dark ? 32 : 48),
                  AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        IconField(
                          controller: _username,
                          icon: dark ? Icons.mail_outline : Icons.person_outline,
                          label: dark ? null : 'OPERATOR ID / EMAIL',
                          hint: dark ? 'Email Address' : 'operator@crimson.net',
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.username],
                        ),
                        const SizedBox(height: 16),
                        IconField(
                          controller: _password,
                          icon: dark ? Icons.lock_outline : Icons.vpn_key_outlined,
                          label: dark ? null : 'SECURITY KEY',
                          hint: dark ? 'Password' : '••••••••',
                          obscureText: _hidePassword,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                          onSubmitted: (_) => _submit(),
                          suffix: IconButton(
                            onPressed: () => setState(() => _hidePassword = !_hidePassword),
                            icon: Icon(
                              _hidePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            SizedBox(
                              width: 22,
                              height: 22,
                              child: Checkbox(
                                value: _rememberMe,
                                onChanged: (value) => setState(() => _rememberMe = value ?? false),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('Remember me', style: Theme.of(context).textTheme.bodySmall),
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Password reset is not available yet.'),
                                  ),
                                );
                              },
                              child: Text(dark ? 'Forgot Password?' : 'Forgot Key?'),
                            ),
                          ],
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
                          label: dark ? 'INITIALIZE SESSION' : 'INITIALIZE CONNECTION',
                          icon: dark ? Icons.login : Icons.arrow_forward,
                          busy: auth.busy,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'OR',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  letterSpacing: 1.6,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 16),
                        AppButton(
                          label: dark ? 'BIOMETRIC AUTH' : 'BIOMETRIC OVERRIDE',
                          outlined: true,
                          icon: Icons.fingerprint,
                          onPressed: auth.busy
                              ? null
                              : () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Biometric login is not available on this device yet.'),
                                    ),
                                  );
                                },
                        ),
                        const SizedBox(height: 32),
                        Text.rich(
                          TextSpan(
                            text: dark ? 'No access protocol? ' : 'Need clearance? ',
                            children: [
                              WidgetSpan(
                                alignment: PlaceholderAlignment.baseline,
                                baseline: TextBaseline.alphabetic,
                                child: GestureDetector(
                                  onTap: auth.busy ? null : _openRegister,
                                  child: Text(
                                    dark ? 'Request clearance' : 'Request clearance',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.secondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
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

class _DarkHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.darkContainerHigh,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Icon(Icons.insights, color: Theme.of(context).colorScheme.secondary, size: 32),
        ),
        const SizedBox(height: 16),
        Text(
          'Crimson Matrix',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(
          'Secure Access Protocol',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _LightHeader extends StatelessWidget {
  const _LightHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.crimson,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.hexagon_outlined, color: AppColors.snow),
        ),
        const SizedBox(height: 24),
        Text(
          'Access Portal',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.8,
            color: AppColors.onyx,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Authenticate to access precision analytics.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
