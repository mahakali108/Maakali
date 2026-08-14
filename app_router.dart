import 'package:flutter/material.dart';
import '../../features/auth/auth_controller.dart';
import '../../features/auth/domain/auth_state.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/users/presentation/screens/access_denied_screen.dart';
import '../../features/users/presentation/screens/role_dashboards/admin_dashboard.dart';
import '../../features/users/presentation/screens/role_dashboards/retailer_dashboard.dart';
import '../../features/users/presentation/screens/role_dashboards/salesman_dashboard.dart';
import '../../features/users/presentation/screens/role_dashboards/staff_dashboard.dart';
import '../../features/users/presentation/screens/role_dashboards/super_admin_dashboard.dart';
import '../constants/app_roles.dart';

/// Root gate. This is intentionally NOT a named-route table — Phase 1 has
/// exactly one decision point (auth + role resolution), so a simple
/// AnimatedBuilder switch is clearer than introducing go_router/named
/// routes for five placeholder screens. Revisit once real per-role
/// navigation stacks exist in later phases.
class AppRoot extends StatelessWidget {
  final AuthController controller;

  const AppRoot({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        switch (controller.resolution) {
          case AuthResolution.loading:
            return const Scaffold(body: Center(child: CircularProgressIndicator()));

          case AuthResolution.unauthenticated:
            return LoginScreen(controller: controller);

          case AuthResolution.accountNotFound:
          case AuthResolution.accountInactive:
            return AccessDeniedScreen(controller: controller, resolution: controller.resolution);

          case AuthResolution.authorized:
            final role = controller.currentAppUser?.role;
            switch (role) {
              case AppRole.superAdmin:
                return SuperAdminDashboard(controller: controller);
              case AppRole.admin:
                return AdminDashboard(controller: controller);
              case AppRole.staff:
                return StaffDashboard(controller: controller);
              case AppRole.salesman:
                return SalesmanDashboard(controller: controller);
              case AppRole.retailer:
                return RetailerDashboard(controller: controller);
              default:
                // Should be unreachable — AuthController already validates
                // the role before setting resolution = authorized. Fail
                // closed rather than guessing a screen.
                return AccessDeniedScreen(controller: controller, resolution: AuthResolution.accountNotFound);
            }
        }
      },
    );
  }
}
