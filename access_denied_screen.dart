import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/auth_controller.dart';
import '../../../auth/domain/auth_state.dart';

class AccessDeniedScreen extends StatelessWidget {
  final AuthController controller;
  final AuthResolution resolution;

  const AccessDeniedScreen({super.key, required this.controller, required this.resolution});

  String get _message {
    switch (resolution) {
      case AuthResolution.accountNotFound:
        return 'No account found for this number.\nPlease contact your administrator.';
      case AuthResolution.accountInactive:
        return 'Your account is currently inactive.\nPlease contact your administrator.';
      default:
        return 'You do not have access to this application.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 56, color: AppColors.textSecondary),
              const SizedBox(height: 18),
              Text(_message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, height: 1.5)),
              const SizedBox(height: 28),
              OutlinedButton(
                onPressed: () => controller.signOut(),
                child: const Text('Sign Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
