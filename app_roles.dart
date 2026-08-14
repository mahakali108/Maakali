/// The ONLY roles that exist in this application.
/// Do not add "customer" or any other role here without an explicit
/// requirement — this list is the single source of truth referenced
/// by Firestore Security Rules, routing, and the user model.
class AppRole {
  AppRole._();

  static const String superAdmin = 'super_admin';
  static const String admin = 'admin';
  static const String staff = 'staff';
  static const String salesman = 'salesman';
  static const String retailer = 'retailer';

  static const List<String> all = [
    superAdmin,
    admin,
    staff,
    salesman,
    retailer,
  ];

  static bool isValid(String? role) => all.contains(role);
}

/// App strings kept centralized for the brand name — never hard-code
/// "Maharani Traders" or the old brand name inline in widgets.
class AppStrings {
  AppStrings._();

  static const String brandName = 'MAHARANI TRADERS';
  static const String tagline = 'Premium B2B Wholesale';
}
