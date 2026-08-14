/// App-level exception with a message that is always safe to show the user.
/// Never surface raw Firebase/Firestore exception text directly in the UI —
/// route every caught error through [AppErrorMapper] first.
class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() => message;
}

class AuthException extends AppException {
  const AuthException(super.message, {super.code});
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Network error. Please check your connection and try again.']);
}

class AccountInactiveException extends AppException {
  const AccountInactiveException()
      : super('Your account is inactive. Please contact your administrator.', code: 'account-inactive');
}

class AccountNotFoundException extends AppException {
  const AccountNotFoundException()
      : super('No account found for this number. Please contact your administrator.', code: 'account-not-found');
}
