/// Carries user-entered registration fields from RegisterScreen through
/// FaydaScanScreen to FaydaConfirmScreen, where they are combined with the
/// Fayda KYC payload before submission.
class RegistrationData {
  const RegistrationData({
    required this.username,
    required this.phoneNumber,
    required this.password,
    required this.role,
  });

  final String username;
  final String phoneNumber;
  final String password;
  final String role;
}
