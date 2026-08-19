import 'package:escrow_et/app.dart';
import 'package:escrow_et/data/session_store.dart';
import 'package:escrow_et/state/auth_controller.dart';
import 'package:escrow_et/ui/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('login screen shows Escrow ET branding', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionStoreProvider.overrideWith((ref) => SessionStore()),
        ],
        child: const EscrowApp(),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Escrow ET'), findsWidgets);
    expect(find.text('Sign in'), findsWidgets);
    expect(find.text('Create an account'), findsOneWidget);
  });

  testWidgets('register offers buyer and seller only', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionStoreProvider.overrideWith((ref) => SessionStore()),
        ],
        child: const MaterialApp(home: RegisterScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('Buyer'), findsOneWidget);
    expect(find.text('Seller'), findsOneWidget);
    expect(find.text('Merchant'), findsNothing);
  });
}
