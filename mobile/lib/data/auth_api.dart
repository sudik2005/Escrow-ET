import '../models/user.dart';
import 'api_client.dart';
import 'api_exception.dart';

class AuthApi {
  AuthApi(this._client);

  final ApiClient _client;

  Future<AuthSession> login({
    required String username,
    required String password,
  }) {
    return _sessionFrom(
      _client.post(
        '/auth/login/',
        body: {'username': username, 'password': password},
      ),
    );
  }

  Future<AuthSession> register({
    required String username,
    required String password,
    required String phoneNumber,
    required String role,
    String email = '',
  }) {
    return _sessionFrom(
      _client.post(
        '/auth/register/',
        body: {
          'username': username,
          'password': password,
          'phone_number': phoneNumber,
          'role': role,
          'email': email,
        },
      ),
    );
  }

  Future<User> me(String token) async {
    final json = await _client.get('/auth/me/', token: token);
    return User.fromJson(json);
  }

  Future<User> updateProfile(
    String token, {
    String? username,
    String? role,
  }) async {
    final json = await _client.patch(
      '/auth/me/',
      token: token,
      body: {
        if (username != null) 'username': username,
        if (role != null) 'role': role,
      },
    );
    return User.fromJson(json);
  }

  Future<void> logout(String token) async {
    try {
      await _client.post('/auth/logout/', token: token);
    } catch (_) {
      // Local sign-out still proceeds if the token is already gone.
    }
  }

  Future<AuthSession> _sessionFrom(Future<Map<String, dynamic>> request) async {
    final json = await request;
    final token = json['token']?.toString() ?? '';
    final userJson = json['user'];
    if (token.isEmpty || userJson is! Map) {
      throw const ApiException('Login response was missing a token.');
    }
    return AuthSession(
      token: token,
      user: User.fromJson(Map<String, dynamic>.from(userJson)),
    );
  }
}
