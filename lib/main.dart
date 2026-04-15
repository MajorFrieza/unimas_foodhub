import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'utils/app_theme.dart';

// ── Auth screens ────────────────────────────────────────────────────────────
import 'screens/splash_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/auth/customer_login_screen.dart';
import 'screens/auth/customer_register_screen.dart';
import 'screens/auth/seller_login_screen.dart';
import 'screens/auth/seller_register_screen.dart';

// ── Customer screens ─────────────────────────────────────────────────────────
import 'screens/customer/stall_list_screen.dart';
import 'screens/customer/stall_menu_screen.dart';
import 'screens/customer/cart_screen.dart';
import 'screens/customer/order_confirmation_screen.dart';
import 'screens/customer/order_history_screen.dart';

// ── Seller screens ───────────────────────────────────────────────────────────
import 'screens/seller/seller_home_screen.dart';
import 'screens/seller/menu_management_screen.dart';
import 'screens/seller/add_edit_menu_item_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const UnimasFoodHubApp());
}

class UnimasFoodHubApp extends StatelessWidget {
  const UnimasFoodHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'UNIMAS FoodHub',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          // Entry
          '/': (_) => const SplashScreen(),
          '/role-selection': (_) => const RoleSelectionScreen(),

          // Customer auth
          '/customer/login': (_) => const CustomerLoginScreen(),
          '/customer/register': (_) => const CustomerRegisterScreen(),

          // Seller auth
          '/seller/login': (_) => const SellerLoginScreen(),
          '/seller/register': (_) => const SellerRegisterScreen(),

          // Customer flow
          '/customer/stalls': (_) => const StallListScreen(),
          '/customer/menu': (_) => const StallMenuScreen(),
          '/customer/cart': (_) => const CartScreen(),
          '/customer/order-confirmation': (_) =>
              const OrderConfirmationScreen(),
          '/customer/orders': (_) => const OrderHistoryScreen(),

          // Seller flow
          '/seller/home': (_) => const SellerHomeScreen(),
          '/seller/menu': (_) => const MenuManagementScreen(),
          '/seller/menu/add': (_) => const AddEditMenuItemScreen(),
        },
      ),
    );
  }
}
