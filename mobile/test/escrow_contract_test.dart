import 'package:escrow_et/models/escrow_contract.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses escrow contract JSON from the API', () {
    final contract = EscrowContract.fromJson({
      'id': '36f0f955-3812-4b2d-84b7-72f998e0510c',
      'buyer_phone': '0922000001',
      'seller_phone': '0911000001',
      'item_name': 'Bluetooth Speaker',
      'amount': '850.00',
      'currency': 'ETB',
      'status': 'PENDING_PAYMENT',
      'delivery_qr_token': 'cf9dddf3-7e26-4e64-bcd7-079d3557279a',
      'pin_is_set': true,
      'payment_link': null,
      'created_at': '2026-08-18T13:40:04.917993+03:00',
      'updated_at': '2026-08-18T13:40:04.934100+03:00',
    });

    expect(contract.itemName, 'Bluetooth Speaker');
    expect(contract.isPendingPayment, isTrue);
    expect(contract.pinIsSet, isTrue);
    expect(contract.paymentLink, isNull);
    expect(contract.statusLabel, 'PENDING PAYMENT');
  });
}
