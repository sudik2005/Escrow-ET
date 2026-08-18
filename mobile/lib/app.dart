import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'state/auth_controller.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/login_screen.dart';
import 'ui/widgets/brand_mark.dart';

class EscrowApp extends ConsumerWidget {
  const EscrowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final isDark = ref.watch(themeControllerProvider);

    return MaterialApp(
      title: 'Escrow ET',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: switch (auth.status) {
        AuthStatus.booting => const _BootScreen(),
        AuthStatus.signedOut => const LoginScreen(),
        AuthStatus.signedIn => const HomeScreen(),
      },
    );
  }
}

class _BootScreen extends StatelessWidget {
  const _BootScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.lightBg,
      body: Center(child: BrandMark(size: 48)),
    );
  }
}
