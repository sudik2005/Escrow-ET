import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api_client.dart';
import '../data/api_exception.dart';
import '../data/auth_api.dart';
import '../data/session_store.dart';
import '../models/user.dart';

final sessionStoreProvider = Provider<SessionStore>((ref) {
  throw UnimplementedError('sessionStoreProvider must be overridden in main()');
});

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(ref.watch(apiClientProvider));
});

enum AuthStatus { booting, signedOut, signedIn }

class AuthState {
  const AuthState({
    required this.status,
    this.session,
    this.busy = false,
    this.error,
  });

  final AuthStatus status;
  final AuthSession? session;
  final bool busy;
  final String? error;

  AuthState copyWith({
    AuthStatus? status,
    AuthSession? session,
    bool? busy,
    String? error,
    bool clearError = false,
    bool clearSession = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      session: clearSession ? null : (session ?? this.session),
      busy: busy ?? this.busy,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthController extends Notifier<AuthState> {
  var _alive = true;

  @override
  AuthState build() {
    _alive = true;
    ref.onDispose(() => _alive = false);
    Future<void>.microtask(_hydrate);
    return const AuthState(status: AuthStatus.booting);
  }

  SessionStore get _store => ref.read(sessionStoreProvider);
  AuthApi get _api => ref.read(authApiProvider);

  Future<void> _hydrate() async {
    final session = await _store.read();
    if (!_alive) {
      return;
    }
    if (session == null) {
      state = const AuthState(status: AuthStatus.signedOut);
      return;
    }
    state = AuthState(status: AuthStatus.signedIn, session: session);
    try {
      final user = await _api.me(session.token);
      final next = AuthSession(token: session.token, user: user);
      await _store.save(next);
      if (!_alive) {
        return;
      }
      state = AuthState(status: AuthStatus.signedIn, session: next);
    } on ApiException catch (error) {
      if (error.statusCode == 401) {
        await _store.clear();
        if (!_alive) {
          return;
        }
        state = const AuthState(status: AuthStatus.signedOut);
      }
    } catch (_) {}
  }

  Future<void> login({
    required String username,
    required String password,
  }) {
    return _authenticate(
      () => _api.login(username: username, password: password),
    );
  }

  Future<void> loginWithFayda({required String rawPayload}) {
    return _authenticate(
      () => _api.loginWithFayda(rawPayload: rawPayload),
    );
  }

  Future<void> register({
    required String username,
    required String password,
    required String phoneNumber,
    required String role,
    String email = '',
  }) {
    return _authenticate(
      () => _api.register(
        username: username,
        password: password,
        phoneNumber: phoneNumber,
        role: role,
        email: email,
      ),
    );
  }

  Future<void> registerWithFayda({
    required String rawPayload,
    required String phoneNumber,
    required String role,
    required String password,
  }) {
    return _authenticate(
      () => _api.registerWithFayda(
        rawPayload: rawPayload,
        phoneNumber: phoneNumber,
        role: role,
        password: password,
      ),
    );
  }

  Future<void> logout() async {
    ref.read(shellTabProvider.notifier).state = 0;
    final token = state.session?.token;
    state = const AuthState(status: AuthStatus.signedOut);
    await _store.clear();
    if (token != null) {
      await _api.logout(token);
    }
  }

  Future<void> updateProfile({String? username, String? role}) async {
    final session = state.session;
    if (session == null) return;
    state = state.copyWith(busy: true, clearError: true);
    try {
      final user = await _api.updateProfile(
        session.token,
        username: username,
        role: role,
      );
      final next = AuthSession(token: session.token, user: user);
      await _store.save(next);
      if (!_alive) return;
      if (role != null) {
        ref.read(shellTabProvider.notifier).state = 0;
      }
      state = AuthState(status: AuthStatus.signedIn, session: next);
    } on ApiException catch (error) {
      if (!_alive) return;
      state = state.copyWith(busy: false, error: error.message);
      rethrow;
    } catch (_) {
      if (!_alive) return;
      state = state.copyWith(busy: false);
      rethrow;
    }
  }

  Future<void> refreshUser() async {
    final session = state.session;
    if (session == null) {
      return;
    }
    try {
      final user = await _api.me(session.token);
      final next = AuthSession(token: session.token, user: user);
      await _store.save(next);
      if (!_alive) {
        return;
      }
      state = AuthState(status: AuthStatus.signedIn, session: next);
    } on ApiException catch (error) {
      if (error.statusCode == 401) {
        await _store.clear();
        if (!_alive) {
          return;
        }
        state = const AuthState(status: AuthStatus.signedOut);
      }
    } catch (_) {}
  }

  Future<void> _authenticate(Future<AuthSession> Function() action) async {
    state = state.copyWith(busy: true, clearError: true);
    try {
      final session = await action();
      await _store.save(session);
      if (!_alive) {
        return;
      }
      state = AuthState(status: AuthStatus.signedIn, session: session);
    } on ApiException catch (error) {
      if (!_alive) {
        return;
      }
      state = state.copyWith(busy: false, error: error.message);
    } catch (_) {
      if (!_alive) {
        return;
      }
      state = state.copyWith(
        busy: false,
        error: 'Something went wrong. Try again.',
      );
    }
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class ThemeController extends Notifier<bool> {
  var _alive = true;

  @override
  bool build() {
    _alive = true;
    ref.onDispose(() => _alive = false);
    Future<void>.microtask(_hydrate);
    return false;
  }

  Future<void> _hydrate() async {
    final theme = ref.read(sessionStoreProvider).theme();
    if (!_alive) {
      return;
    }
    state = theme == 'dark';
  }

  Future<void> toggle() async {
    state = !state;
    await ref.read(sessionStoreProvider).setTheme(state ? 'dark' : 'light');
  }
}

final themeControllerProvider = NotifierProvider<ThemeController, bool>(
  ThemeController.new,
);

final shellTabProvider = StateProvider<int>((ref) => 0);
