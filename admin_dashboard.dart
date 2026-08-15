import 'package:flutter/material.dart';
import '../../../../auth/auth_controller.dart';
import 'dashboard_placeholder.dart';

class AdminDashboard extends StatelessWidget {
  final AuthController controller;
  const AdminDashboard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) =>
      DashboardPlaceholder(title: 'Admin', controller: controller);
}
