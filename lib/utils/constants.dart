class AppConstants {
  // App info
  static const String appName = 'UNIMAS FoodHub';
  static const String appVersion = '1.0.0';

  // User roles
  static const String roleCustomer = 'customer';
  static const String roleSeller = 'seller';

  // Order statuses
  static const String statusPending = 'pending';
  static const String statusPreparing = 'preparing';
  static const String statusReady = 'ready';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';

  // Firebase DB paths
  static const String usersPath = 'users';
  static const String sellersPath = 'sellers';
  static const String menuItemsPath = 'menuItems';
  static const String ordersPath = 'orders';

  // Menu categories
  static const List<String> menuCategories = [
    'All',
    'Rice',
    'Noodles',
    'Bread & Pastry',
    'Drinks',
    'Snacks',
    'Desserts',
    'Others',
  ];

  // Pickup code prefix
  static const String pickupPrefix = 'FH';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxMenuItemNameLength = 60;
  static const double maxMenuItemPrice = 999.99;

  // UI
  static const double defaultPadding = 16.0;
  static const double cardRadius = 16.0;
  static const double buttonRadius = 12.0;
}
