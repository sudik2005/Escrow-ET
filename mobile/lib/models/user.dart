class User {
  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.kycVerified,
    this.balance = '0.00',
  });

  final String id;
  final String username;
  final String email;
  final String phoneNumber;
  final String role;
  final bool kycVerified;
  final String balance;

  bool get isSeller => role == 'SELLER';
  bool get isBuyer => role == 'BUYER';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      kycVerified: json['kyc_verified'] == true,
      balance: json['balance']?.toString() ?? '0.00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone_number': phoneNumber,
      'role': role,
      'kyc_verified': kycVerified,
      'balance': balance,
    };
  }
}

class AuthSession {
  const AuthSession({required this.token, required this.user});

  final String token;
  final User user;
}
