import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'state/auth_controller.dart';
import 'theme/app_theme.dart';
import 'ui/screens/login_screen.dart';
import 'ui/shell/main_shell.dart';
import 'ui/widgets/brand_mark.dart';

class EscrowApp extends ConsumerWidget {
  const EscrowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final isDark = ref.watch(themeControllerProvider);

    final session = auth.session;
    return MaterialApp(
      key: ValueKey(
        '${auth.status}-${session?.user.id ?? ''}-${session?.user.role ?? ''}',
      ),
      title: 'Escrow ET',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: switch (auth.status) {
        AuthStatus.booting => const _BootScreen(),
        AuthStatus.signedOut => const LoginScreen(),
        AuthStatus.signedIn => const MainShell(),
      },
    );
  }
}

class _BootScreen extends StatelessWidget {
  const _BootScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: BrandMark(size: 48)),
    );
  }
}
