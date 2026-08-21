import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

import 'app.dart';
import 'data/session_store.dart';
import 'state/auth_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && ImagePickerPlatform.instance is ImagePickerAndroid) {
    (ImagePickerPlatform.instance as ImagePickerAndroid).useAndroidPhotoPicker =
        true;
  }
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
