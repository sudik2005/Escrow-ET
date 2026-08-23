import 'package:escrow_et/fayda/fayda_decoder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('decodePayload extracts V4 identity fields', () {
    const payload =
        'UklGRjQAAAB:DLT:Abebe Kebede Alemu:V:4:G:M:A:6140123412341234'
        ':D:2002/11/26:SIGN:eyJhbGciOiJSUzI1NiJ9..c2ln';
    final result = decodePayload(payload);
    expect(result, isA<FaydaResultOk>());
    final data = (result as FaydaResultOk).data;
    expect(data.fullName, 'Abebe Kebede Alemu');
    expect(data.gender, 'M');
    expect(data.fan, '6140123412341234');
    expect(data.dateOfBirth, '2002-11-26');
    expect(data.payloadVersion, '4');
  });

  test('decodeAndVerify rejects a forged signature', () {
    const payload =
        'UklGRjQAAAB:DLT:Abebe Kebede Alemu:V:4:G:M:A:6140123412341234'
        ':D:2002/11/26:SIGN:eyJhbGciOiJSUzI1NiJ9..c2ln';
    final result = decodeAndVerify(payload);
    expect(result, isA<FaydaResultErr>());
    expect(
      (result as FaydaResultErr).error.code,
      anyOf(FaydaErrorCode.invalidSignature, FaydaErrorCode.malformedJws),
    );
  });

  test('decodePayload rejects non-Fayda text', () {
    final result = decodePayload('hello');
    expect(result, isA<FaydaResultErr>());
    expect((result as FaydaResultErr).error.code, FaydaErrorCode.notFayda);
  });
}
