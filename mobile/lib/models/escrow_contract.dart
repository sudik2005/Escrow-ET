class EscrowContract {
  const EscrowContract({
    required this.id,
    required this.buyerPhone,
    required this.sellerPhone,
    required this.itemName,
    required this.amount,
    required this.currency,
    required this.status,
    this.deliveryQrToken,
    required this.pinIsSet,
    this.paymentLink,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String buyerPhone;
  final String sellerPhone;
  final String itemName;
  final String amount;
  final String currency;
  final String status;
  final String? deliveryQrToken;
  final bool pinIsSet;
  final String? paymentLink;
  final String? createdAt;
  final String? updatedAt;

  bool get isPendingPayment => status == 'PENDING_PAYMENT';
  bool get isFunded => status == 'FUNDED';
  bool get isInTransit => status == 'IN_TRANSIT';
  bool get canConfirm => status == 'FUNDED' || status == 'IN_TRANSIT';
  bool get canDispute =>
      status == 'FUNDED' ||
      status == 'IN_TRANSIT' ||
      status == 'DELIVERED_UNVERIFIED';

  String get statusLabel => status.replaceAll('_', ' ');

  EscrowContract copyWith({String? paymentLink, String? status}) {
    return EscrowContract(
      id: id,
      buyerPhone: buyerPhone,
      sellerPhone: sellerPhone,
      itemName: itemName,
      amount: amount,
      currency: currency,
      status: status ?? this.status,
      deliveryQrToken: deliveryQrToken,
      pinIsSet: pinIsSet,
      paymentLink: paymentLink ?? this.paymentLink,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory EscrowContract.fromJson(Map<String, dynamic> json) {
    return EscrowContract(
      id: json['id']?.toString() ?? '',
      buyerPhone: json['buyer_phone']?.toString() ?? '',
      sellerPhone: json['seller_phone']?.toString() ?? '',
      itemName: json['item_name']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '0.00',
      currency: json['currency']?.toString() ?? 'ETB',
      status: json['status']?.toString() ?? '',
      deliveryQrToken: _optional(json['delivery_qr_token']),
      pinIsSet: json['pin_is_set'] == true,
      paymentLink: _optional(json['payment_link']),
      createdAt: _optional(json['created_at']),
      updatedAt: _optional(json['updated_at']),
    );
  }
}

String? _optional(Object? value) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty || text == 'null') {
    return null;
  }
  return text;
}
