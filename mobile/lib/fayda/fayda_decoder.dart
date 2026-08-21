// Fayda ID QR decoder — Dart port of fayda-decoder (SPEC.md §1–§2)
// plus detached RS256 JWS verification against the pinned NIDP V4 key.

import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/asn1.dart';
import 'package:pointycastle/export.dart';

/// A successfully decoded Fayda card.
class FaydaSuccess {
  final String fullName;
  final String? gender; // "M" or "F"
  final String? fan; // Fayda Account Number
  final String? dateOfBirth; // ISO yyyy-mm-dd
  final List<int>? faceBytes; // WebP image bytes (null unless includeFace: true)
  final String payloadVersion;
  final String rawPayload;
  final Map<String, String> rawMap;
  final String? jws;

  const FaydaSuccess({
    required this.fullName,
    this.gender,
    this.fan,
    this.dateOfBirth,
    this.faceBytes,
    required this.payloadVersion,
    required this.rawPayload,
    required this.rawMap,
    this.jws,
  });

  String get genderLabel {
    switch (gender) {
      case 'M':
        return 'Male';
      case 'F':
        return 'Female';
      default:
        return '—';
    }
  }
}

class FaydaFailure {
  final FaydaErrorCode code;
  final String message;

  const FaydaFailure({required this.code, required this.message});
}

sealed class FaydaResult {}

class FaydaResultOk extends FaydaResult {
  final FaydaSuccess data;
  FaydaResultOk(this.data);
}

class FaydaResultErr extends FaydaResult {
  final FaydaFailure error;
  FaydaResultErr(this.error);
}

enum FaydaErrorCode {
  noQrFound,
  qrUnreadable,
  notFayda,
  unsupportedVersion,
  signatureMissing,
  malformedJws,
  unsupportedAlgorithm,
  invalidSignature,
  missingFan,
}

class FaydaSignatureVerification {
  final bool verified;
  final FaydaErrorCode? reason;

  const FaydaSignatureVerification({required this.verified, this.reason});
}

const _supportedVersions = {'4'};

/// Provenance: recovered from https://id.et/scanId (observed 2026-08-16).
/// SPKI SHA-256: 803dcd26057edc1423a5b9655f03c945b84a146be28caa754bc460a3fea6624a
const faydaV4PublicKeyPem = '''
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxMWfApFZBq/qIotUjrkY
bdyXQcHOUgZsqZy3QUcXr50t+DfwYKkSfMnTZFHekptAWA4HM5upav6xqFuP+3Pi
KmajY2Imkl60bF4Bt9qcch74jPSObH/1CE0xs75dqLb+CfoTG1+i4n3Fz5cN9Mxp
EGE7pmvIdYtaAUCoKA/cjQ5QY426ttp4EQcnh5vmyr1e7ur9LjqVVsurfefxlsR+
sRfB2RFuaEGrLO/75UeUSY2x1nTHzOvycWYaCve1YfunHkXA8JvUy73+b33ixIgw
QuqUkOuyKhytFr5l6N1gfjTvOOysclCH5o8jy7KyzgyK17kHXPAaKuxYXH9pGtAF
0wIDAQAB
-----END PUBLIC KEY-----
''';

/// Parse the raw QR text from a Fayda card.
FaydaResult decodePayload(String text, {bool includeFace = false}) {
  final payload = text.trim();

  if (!payload.contains(':DLT:') || !payload.contains(':SIGN:')) {
    return FaydaResultErr(const FaydaFailure(
      code: FaydaErrorCode.notFayda,
      message: 'The QR payload is not a recognizable Fayda ID structure.',
    ));
  }

  final dltIdx = payload.indexOf(':DLT:');
  final facePart = payload.substring(0, dltIdx);
  final rest = payload.substring(dltIdx + ':DLT:'.length);

  final signIdx = rest.indexOf(':SIGN:');
  if (signIdx == -1) {
    return FaydaResultErr(const FaydaFailure(
      code: FaydaErrorCode.notFayda,
      message: 'The QR payload is not a recognizable Fayda ID structure.',
    ));
  }

  final fieldsPart = rest.substring(0, signIdx);
  final jws = rest.substring(signIdx + ':SIGN:'.length);

  final segments = fieldsPart.split(':');
  final fullName = segments.isNotEmpty ? segments.first.trim() : '';
  if (fullName.isEmpty) {
    return FaydaResultErr(const FaydaFailure(
      code: FaydaErrorCode.notFayda,
      message: 'The QR payload is not a recognizable Fayda ID structure.',
    ));
  }

  final tail = segments.sublist(1);
  final rawMap = <String, String>{};
  for (var i = 0; i + 1 < tail.length; i += 2) {
    rawMap[tail[i]] = tail[i + 1];
  }

  final version = rawMap['V'];
  if (version == null || !_supportedVersions.contains(version)) {
    return FaydaResultErr(FaydaFailure(
      code: FaydaErrorCode.unsupportedVersion,
      message: 'Unsupported payload version: $version. Update the app.',
    ));
  }

  return FaydaResultOk(FaydaSuccess(
    fullName: fullName,
    gender: _parseGender(rawMap['G']),
    fan: _parseFan(rawMap['A']),
    dateOfBirth: _parseDob(rawMap['D']),
    faceBytes: includeFace ? _parseFace(facePart) : null,
    payloadVersion: version,
    rawPayload: payload,
    rawMap: rawMap,
    jws: jws.isEmpty ? null : jws,
  ));
}

/// Decode then verify the detached RS256 JWS. Rejects missing FAN.
FaydaResult decodeAndVerify(String text, {bool includeFace = false}) {
  final decoded = decodePayload(text, includeFace: includeFace);
  if (decoded is FaydaResultErr) {
    return decoded;
  }
  final data = (decoded as FaydaResultOk).data;
  if (data.fan == null || data.fan!.isEmpty) {
    return FaydaResultErr(const FaydaFailure(
      code: FaydaErrorCode.missingFan,
      message: 'The Fayda QR did not include a valid Fayda number.',
    ));
  }
  final authenticity = verifySignature(data);
  if (!authenticity.verified) {
    return FaydaResultErr(FaydaFailure(
      code: authenticity.reason ?? FaydaErrorCode.invalidSignature,
      message: _verifyMessage(authenticity.reason),
    ));
  }
  return FaydaResultOk(data);
}

FaydaSignatureVerification verifySignature(
  FaydaSuccess result, {
  String? publicKeyPem,
}) {
  final jws = result.jws;
  if (jws == null || jws.isEmpty) {
    return const FaydaSignatureVerification(
      verified: false,
      reason: FaydaErrorCode.signatureMissing,
    );
  }
  if (result.payloadVersion != '4' && publicKeyPem == null) {
    return const FaydaSignatureVerification(
      verified: false,
      reason: FaydaErrorCode.unsupportedVersion,
    );
  }

  final parts = jws.split('.');
  if (parts.length != 3 ||
      parts[0].isEmpty ||
      parts[1].isNotEmpty ||
      parts[2].isEmpty) {
    return const FaydaSignatureVerification(
      verified: false,
      reason: FaydaErrorCode.malformedJws,
    );
  }

  try {
    final headerJson = utf8.decode(_base64UrlDecode(parts[0]));
    final header = jsonDecode(headerJson);
    if (header is! Map || header['alg'] != 'RS256') {
      return const FaydaSignatureVerification(
        verified: false,
        reason: FaydaErrorCode.unsupportedAlgorithm,
      );
    }
  } catch (_) {
    return const FaydaSignatureVerification(
      verified: false,
      reason: FaydaErrorCode.malformedJws,
    );
  }

  final markerIndex = result.rawPayload.lastIndexOf(':SIGN:');
  if (markerIndex == -1) {
    return const FaydaSignatureVerification(
      verified: false,
      reason: FaydaErrorCode.malformedJws,
    );
  }

  try {
    final detachedPayload = result.rawPayload.substring(0, markerIndex);
    final signingInput =
        '${parts[0]}.${_base64UrlEncode(utf8.encode(detachedPayload))}';
    final signature = _base64UrlDecode(parts[2]);
    final key = _rsaPublicKeyFromPem(publicKeyPem ?? faydaV4PublicKeyPem);
    final signer = RSASigner(SHA256Digest(), '0609608648016503040201');
    signer.init(false, PublicKeyParameter<RSAPublicKey>(key));
    final ok = signer.verifySignature(
      Uint8List.fromList(utf8.encode(signingInput)),
      RSASignature(signature),
    );
    return FaydaSignatureVerification(
      verified: ok,
      reason: ok ? null : FaydaErrorCode.invalidSignature,
    );
  } catch (_) {
    return const FaydaSignatureVerification(
      verified: false,
      reason: FaydaErrorCode.invalidSignature,
    );
  }
}

String _verifyMessage(FaydaErrorCode? reason) {
  switch (reason) {
    case FaydaErrorCode.signatureMissing:
      return 'The Fayda QR is missing a signature.';
    case FaydaErrorCode.malformedJws:
      return 'The Fayda QR signature is malformed.';
    case FaydaErrorCode.unsupportedAlgorithm:
      return 'The Fayda QR uses an unsupported signature algorithm.';
    case FaydaErrorCode.unsupportedVersion:
      return 'Unsupported Fayda card version. Update the app.';
    default:
      return 'This Fayda QR signature is not valid.';
  }
}

String faydaScanErrorMessage(FaydaErrorCode code) {
  switch (code) {
    case FaydaErrorCode.notFayda:
      return 'QR found, but it is not a Fayda ID.\nScan the back of the card.';
    case FaydaErrorCode.unsupportedVersion:
      return 'Unsupported card version. Please update the app.';
    case FaydaErrorCode.noQrFound:
      return 'No QR code found. Retake the photo with more light.';
    case FaydaErrorCode.qrUnreadable:
      return 'QR code unreadable. Try a clearer photo.';
    case FaydaErrorCode.signatureMissing:
    case FaydaErrorCode.malformedJws:
    case FaydaErrorCode.unsupportedAlgorithm:
    case FaydaErrorCode.invalidSignature:
      return 'This Fayda card could not be verified.';
    case FaydaErrorCode.missingFan:
      return 'The Fayda QR did not include a valid Fayda number.';
  }
}

String? _parseGender(String? value) =>
    (value == 'M' || value == 'F') ? value : null;

String? _parseFan(String? value) {
  if (value == null) return null;
  return RegExp(r'^\d{10,20}$').hasMatch(value) ? value : null;
}

String? _parseDob(String? value) {
  if (value == null) return null;
  final re = RegExp(r'^(\d{4})/(\d{2})/(\d{2})$');
  final m = re.firstMatch(value);
  if (m == null) return null;
  final y = int.parse(m.group(1)!);
  final mo = int.parse(m.group(2)!);
  final d = int.parse(m.group(3)!);
  try {
    final dt = DateTime.utc(y, mo, d);
    if (dt.year != y || dt.month != mo || dt.day != d) return null;
    return '${m.group(1)}-${m.group(2)}-${m.group(3)}';
  } catch (_) {
    return null;
  }
}

List<int>? _parseFace(String facePart) {
  if (facePart.isEmpty) return null;
  try {
    final bytes = _base64UrlDecode(facePart);
    if (bytes.length < 4) return null;
    if (bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46) {
      return bytes;
    }
    return null;
  } catch (_) {
    return null;
  }
}

Uint8List _base64UrlDecode(String input) {
  var b64 = input.replaceAll('-', '+').replaceAll('_', '/');
  final rem = b64.length % 4;
  if (rem != 0) b64 += '=' * (4 - rem);
  return Uint8List.fromList(base64.decode(b64));
}

String _base64UrlEncode(List<int> input) {
  return base64Url.encode(input).replaceAll('=', '');
}

RSAPublicKey _rsaPublicKeyFromPem(String pem) {
  final body = pem
      .replaceAll('-----BEGIN PUBLIC KEY-----', '')
      .replaceAll('-----END PUBLIC KEY-----', '')
      .replaceAll(RegExp(r'\s+'), '');
  final der = Uint8List.fromList(base64.decode(body));
  final parser = ASN1Parser(der);
  final top = parser.nextObject() as ASN1Sequence;
  final bitString = top.elements![1] as ASN1BitString;
  final keyBytes = Uint8List.fromList(bitString.stringValues!);
  final keyParser = ASN1Parser(keyBytes);
  final keySeq = keyParser.nextObject() as ASN1Sequence;
  final modulus = (keySeq.elements![0] as ASN1Integer).integer!;
  final exponent = (keySeq.elements![1] as ASN1Integer).integer!;
  return RSAPublicKey(modulus, exponent);
}
