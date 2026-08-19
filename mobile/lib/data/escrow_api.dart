import '../models/escrow_contract.dart';
import 'api_client.dart';
import 'api_exception.dart';

class EscrowApi {
  EscrowApi(this._client);

  final ApiClient _client;

  Future<List<EscrowContract>> mine(String token) async {
    final rows = await _client.getList('/escrow/mine/', token: token);
    return [for (final row in rows) EscrowContract.fromJson(row)];
  }

  Future<EscrowContract> getOne(String token, String id) async {
    final json = await _client.get('/escrow/$id/', token: token);
    return EscrowContract.fromJson(json);
  }

  Future<EscrowContract> create({
    required String token,
    required String buyerPhone,
    required String itemName,
    required String amount,
    required String pin,
  }) async {
    final json = await _client.post(
      '/escrow/create/',
      token: token,
      body: {
        'buyer_phone': buyerPhone,
        'item_name': itemName,
        'amount': amount,
        'verification_pin': pin,
      },
    );
    return EscrowContract.fromJson(json);
  }

  Future<EscrowContract> markShipped(String token, String id) async {
    final json = await _client.post('/escrow/$id/mark-shipped/', token: token);
    return EscrowContract.fromJson(json);
  }

  Future<EscrowContract> confirmDelivery({
    required String token,
    required String id,
    String? pin,
    String? qrToken,
  }) async {
    final json = await _client.post(
      '/escrow/$id/confirm-delivery/',
      token: token,
      body: {
        if (pin != null && pin.isNotEmpty) 'pin': pin,
        if (qrToken != null && qrToken.isNotEmpty) 'qr_token': qrToken,
      },
    );
    return EscrowContract.fromJson(json);
  }

  Future<EscrowContract> openDispute({
    required String token,
    required String id,
    required String reason,
  }) async {
    final json = await _client.post(
      '/escrow/$id/dispute/',
      token: token,
      body: {'reason': reason},
    );
    return EscrowContract.fromJson(json);
  }

  Future<EscrowContract> sandboxFund(String token, String id) async {
    final json = await _client.post('/escrow/$id/sandbox-fund/', token: token);
    return EscrowContract.fromJson(json);
  }

  Future<String> pay(String token, String id) async {
    final json = await _client.post('/escrow/$id/pay/', token: token);
    final link = json['payment_link']?.toString() ?? '';
    if (link.isEmpty) {
      throw const ApiException('Could not get a payment link. Try again shortly.');
    }
    return link;
  }
}
