import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/auth_controller.dart';
import '../../theme/app_colors.dart';
import '../widgets/app_controls.dart';
import '../widgets/app_header.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _bio;
  var _push = true;
  var _digest = false;
  var _twoFactor = true;

  @override
  void initState() {
    super.initState();
    final store = ref.read(sessionStoreProvider);
    final user = ref.read(authControllerProvider).session?.user;
    _name = TextEditingController(text: user?.username ?? '');
    _email = TextEditingController(text: user?.email ?? '');
    _phone = TextEditingController(text: user?.phoneNumber ?? '');
    _bio = TextEditingController(text: store.text('bio'));
    _push = store.flag('push_notifications', fallback: true);
    _digest = store.flag('email_digests');
    _twoFactor = store.flag('two_factor', fallback: true);
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final store = ref.read(sessionStoreProvider);
    await store.setText('bio', _bio.text.trim());
    await store.setFlag('push_notifications', _push);
    await store.setFlag('email_digests', _digest);
    await store.setFlag('two_factor', _twoFactor);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Local preferences saved. Profile edits still go through the API.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).session?.user;
    final isDark = ref.watch(themeControllerProvider);
    final dark = AppColors.isDark(context);
    final roleLabel = switch (user?.role) {
      'SELLER' => 'Seller node',
      'BUYER' => 'Buyer node',
      _ => user?.role ?? '',
    };

    return Column(
      children: [
        const AppHeader(title: 'Profile Settings', centerTitle: true, showAvatar: false),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: dark ? AppColors.darkContainerHigh : AppColors.lightContainer,
                      child: Text(
                        (user?.username.isNotEmpty ?? false) ? user!.username[0].toUpperCase() : '?',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.username ?? '',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(roleLabel, style: Theme.of(context).textTheme.bodySmall),
                    if (user?.kycVerified == true)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          'KYC verified',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              _SectionLabel('Personal Info'),
              const SizedBox(height: 8),
              _Group(
                children: [
                  _LabeledField(label: 'Full Name', icon: Icons.person_outline, controller: _name, readOnly: true),
                  _LabeledField(
                    label: 'Email Address',
                    icon: Icons.mail_outline,
                    controller: _email,
                    readOnly: true,
                  ),
                  _LabeledField(label: 'Phone', icon: Icons.phone_outlined, controller: _phone, readOnly: true),
                  _LabeledField(label: 'Bio', icon: Icons.info_outline, controller: _bio, maxLines: 3),
                ],
              ),
              const SizedBox(height: 32),
              _SectionLabel('Security'),
              const SizedBox(height: 8),
              _Group(
                children: [
                  _RowTile(
                    icon: Icons.password,
                    title: 'Change Password',
                    subtitle: 'Managed by the auth API',
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Password change is not available from the phone app yet.')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _RowTile(
                    icon: Icons.shield_outlined,
                    title: 'Two-Factor Auth',
                    subtitle: 'Authenticator App',
                    trailing: Switch(
                      value: _twoFactor,
                      onChanged: (value) => setState(() => _twoFactor = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _SectionLabel('Notifications'),
              const SizedBox(height: 8),
              _Group(
                children: [
                  _RowTile(
                    icon: Icons.notifications_active_outlined,
                    title: 'Push Notifications',
                    subtitle: 'Security alerts and updates',
                    trailing: Switch(value: _push, onChanged: (value) => setState(() => _push = value)),
                  ),
                  const Divider(height: 1),
                  _RowTile(
                    icon: Icons.mark_email_unread_outlined,
                    title: 'Email Digests',
                    subtitle: 'Weekly performance reports',
                    trailing: Switch(value: _digest, onChanged: (value) => setState(() => _digest = value)),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _SectionLabel('Appearance'),
              const SizedBox(height: 8),
              _Group(
                children: [
                  _RowTile(
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark mode',
                    subtitle: 'Crimson Matrix night protocol',
                    trailing: Switch(
                      value: isDark,
                      onChanged: (_) => ref.read(themeControllerProvider.notifier).toggle(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              AppButton(
                label: 'SAVE CHANGES',
                icon: Icons.save_outlined,
                onPressed: _save,
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'LOG OUT',
                outlined: true,
                onPressed: () => ref.read(authControllerProvider.notifier).logout(),
              ),
            ],
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
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.secondary,
        letterSpacing: 1.4,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: dark ? AppColors.darkSurface : AppColors.snow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.icon,
    required this.controller,
    this.readOnly = false,
    this.maxLines = 1,
  });

  final String label;
  final IconData icon;
  final TextEditingController controller;
  final bool readOnly;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          TextField(
            controller: controller,
            readOnly: readOnly,
            maxLines: maxLines,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 20),
              filled: false,
              border: const UnderlineInputBorder(),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RowTile extends StatelessWidget {
  const _RowTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: dark ? AppColors.darkContainer : AppColors.lightContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.bodyMedium),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
