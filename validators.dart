class Validators {
  Validators._();

  /// Accepts a 10-digit Indian mobile number (no country code).
  static bool isValidIndianMobile(String input) {
    final digits = input.trim();
    return RegExp(r'^[6-9]\d{9}$').hasMatch(digits);
  }

  /// Converts a bare 10-digit number to E.164 format for Firebase Auth.
  static String toE164India(String input) {
    final digits = input.trim();
    return '+91$digits';
  }

  static bool isValidOtp(String input) {
    return RegExp(r'^\d{6}$').hasMatch(input.trim());
  }
}
