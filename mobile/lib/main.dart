import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'data/session_store.dart';
import 'state/auth_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final store = SessionStore();
  await store.open();

  runApp(
    ProviderScope(
      overrides: [sessionStoreProvider.overrideWith((ref) => store)],
      child: const EscrowApp(),
    ),
  );
}
