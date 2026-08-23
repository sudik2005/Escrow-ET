class User {
  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.kycVerified,
    this.balance = '0.00',
    this.legalName = '',
    this.gender = '',
    this.faydaNumber,
  });

  final String id;
  final String username;
  final String email;
  final String phoneNumber;
  final String role;
  final bool kycVerified;
  final String balance;
  final String legalName;
  final String gender;
  final String? faydaNumber;

  bool get isSeller => role == 'SELLER';
  bool get isBuyer => role == 'BUYER';

  String get displayName {
    final name = legalName.trim();
    if (name.isNotEmpty) return name;
    if (username.isNotEmpty) return username;
    return 'there';
  }

  String get firstName {
    final parts = displayName.split(RegExp(r'\s+'));
    return parts.isEmpty ? displayName : parts.first;
  }

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

  String get maskedFaydaNumber {
    final fan = faydaNumber;
    if (fan == null || fan.isEmpty) return '—';
    if (fan.length <= 4) return fan;
    return '${'*' * (fan.length - 4)}${fan.substring(fan.length - 4)}';
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      kycVerified: json['kyc_verified'] == true,
      balance: json['balance']?.toString() ?? '0.00',
      legalName: json['legal_name']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      faydaNumber: json['fayda_number']?.toString(),
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
      'legal_name': legalName,
      'gender': gender,
      'fayda_number': faydaNumber,
    };
  }
}

class AuthSession {
  const AuthSession({required this.token, required this.user});

  final String token;
  final User user;
}
