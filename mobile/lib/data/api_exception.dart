class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;

  static String fromBody(Object? body) {
    if (body is Map) {
      final error = body['error'] ?? body['detail'];
      if (error is String && error.isNotEmpty) {
        return error;
      }
      final parts = <String>[];
      body.forEach((key, value) {
        if (key == 'error' || key == 'detail') {
          return;
        }
        if (value is List) {
          parts.add('$key: ${value.map((item) => item.toString()).join(', ')}');
        } else if (value != null) {
          parts.add('$key: $value');
        }
      });
      if (parts.isNotEmpty) {
        return parts.join('\n');
      }
    }
    return 'Something went wrong. Try again.';
  }
}
