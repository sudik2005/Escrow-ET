String normalizeEtPhone(String value) {
  final digits = value.replaceAll(RegExp(r'\D'), '');
  final String local;
  if (digits.startsWith('251') && digits.length >= 12) {
    local = digits.substring(3);
  } else if (digits.startsWith('0')) {
    local = digits.substring(1);
  } else {
    local = digits;
  }
  if (local.length == 9) return '+251$local';
  return value.trim();
}

bool sameEtPhone(String a, String b) {
  final left = normalizeEtPhone(a);
  final right = normalizeEtPhone(b);
  return left.isNotEmpty && left == right;
}
