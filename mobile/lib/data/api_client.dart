import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_exception.dart';

class ApiClient {
  ApiClient({String? baseUrl, http.Client? httpClient})
    : baseUrl = _normalize(baseUrl ?? defaultBaseUrl()),
      _http = httpClient ?? http.Client();

  final String baseUrl;
  final http.Client _http;

  static String defaultBaseUrl() {
    const fromDefine = String.fromEnvironment('API_BASE_URL');
    if (fromDefine.isNotEmpty) {
      return fromDefine;
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api';
    }
    return 'http://127.0.0.1:8000/api';
  }

  static String _normalize(String url) {
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) {
    return _send('POST', path, body: body, token: token);
  }

  Future<Map<String, dynamic>> get(String path, {String? token}) {
    return _send('GET', path, token: token);
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Token $token',
    };

    http.Response response;
    try {
      response = switch (method) {
        'GET' => await _http.get(uri, headers: headers).timeout(const Duration(seconds: 20)),
        _ => await _http
            .post(uri, headers: headers, body: jsonEncode(body ?? {}))
            .timeout(const Duration(seconds: 20)),
      };
    } on SocketException {
      throw const ApiException(
        'Cannot reach the server. Start Django, then check API_BASE_URL.',
      );
    } on TimeoutException {
      throw const ApiException('The server took too long to respond.');
    } on HttpException {
      throw const ApiException('Cannot reach the server.');
    } on FormatException {
      throw const ApiException('The server sent a bad response.');
    }

    Object? decoded;
    if (response.body.isNotEmpty) {
      try {
        decoded = jsonDecode(response.body);
      } on FormatException {
        decoded = response.body;
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        ApiException.fromBody(decoded),
        statusCode: response.statusCode,
      );
    }

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }
    return <String, dynamic>{};
  }
}
