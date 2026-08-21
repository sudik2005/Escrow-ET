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

  testWidgets('login screen offers Fayda sign-in', (tester) async {
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

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('SIGN IN WITH FAYDA'), findsOneWidget);
    expect(find.text('Use password instead'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
  });

  testWidgets('register requires a Fayda scan', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionStoreProvider.overrideWith((ref) => SessionStore()),
        ],
        child: const MaterialApp(home: RegisterScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('SCAN FAYDA ID'), findsOneWidget);
    expect(find.text('Merchant'), findsNothing);
  });
}
