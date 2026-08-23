from django.test import SimpleTestCase

from core.fayda import FaydaError, _decode_payload, verify_and_decode


class FaydaDecoderTests(SimpleTestCase):
    def test_rejects_non_fayda_text(self):
        with self.assertRaises(FaydaError) as ctx:
            verify_and_decode("hello world")
        self.assertEqual(ctx.exception.code, "NOT_FAYDA")

    def test_parses_v4_fields_before_signature_check(self):
        payload = (
            "UklGRjQAAAB:DLT:Abebe Kebede Alemu:V:4:G:M:A:6140123412341234"
            ":D:2002/11/26:SIGN:eyJhbGciOiJSUzI1NiJ9..sig"
        )
        parsed = _decode_payload(payload)
        self.assertEqual(parsed.full_name, "Abebe Kebede Alemu")
        self.assertEqual(parsed.gender, "M")
        self.assertEqual(parsed.fan, "6140123412341234")
        self.assertEqual(parsed.date_of_birth.isoformat(), "2002-11-26")
        self.assertEqual(parsed.payload_version, "4")

    def test_rejects_invalid_signature(self):
        payload = (
            "UklGRjQAAAB:DLT:Abebe Kebede Alemu:V:4:G:M:A:6140123412341234"
            ":D:2002/11/26:SIGN:eyJhbGciOiJSUzI1NiJ9..c2ln"
        )
        with self.assertRaises(FaydaError) as ctx:
            verify_and_decode(payload)
        self.assertIn(ctx.exception.code, {"INVALID_SIGNATURE", "MALFORMED_JWS"})
