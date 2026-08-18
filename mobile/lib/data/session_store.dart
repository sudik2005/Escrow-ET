import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/user.dart';

class SessionStore {
  SessionStore({Box<dynamic>? box}) : _box = box;

  static const boxName = 'session';

  Box<dynamic>? _box;

  Future<void> open() async {
    _box ??= await Hive.openBox<dynamic>(boxName);
  }

  Future<AuthSession?> read() async {
    final box = _box;
    if (box == null) {
      return null;
    }
    final token = box.get('token') as String?;
    final rawUser = box.get('user') as String?;
    if (token == null || token.isEmpty || rawUser == null) {
      return null;
    }
    final decoded = jsonDecode(rawUser);
    if (decoded is! Map) {
      return null;
    }
    return AuthSession(
      token: token,
      user: User.fromJson(Map<String, dynamic>.from(decoded)),
    );
  }

  Future<void> save(AuthSession session) async {
    await _box?.put('token', session.token);
    await _box?.put('user', jsonEncode(session.user.toJson()));
  }

  Future<void> clear() async {
    await _box?.delete('token');
    await _box?.delete('user');
  }

  String theme() => (_box?.get('theme') as String?) ?? 'light';

  Future<void> setTheme(String theme) async {
    await _box?.put('theme', theme);
  }
}
