import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'services/notification_service.dart';
import 'utils/app_theme.dart';

// ── Entry ────────────────────────────────────────────────────────────────────
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';

// ── Auth screens ─────────────────────────────────────────────────────────────
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';

// ── Customer scaffold & screens ───────────────────────────────────────────────
import 'screens/customer/customer_scaffold.dart';
import 'screens/customer/search_screen.dart';
import 'screens/customer/stall_menu_screen.dart';
import 'screens/customer/food_item_detail_screen.dart';
import 'screens/customer/cart_screen.dart';
import 'screens/customer/order_tracking_screen.dart';

// ── Seller scaffold & screens ─────────────────────────────────────────────────
import 'screens/seller/seller_scaffold.dart';
import 'screens/seller/add_edit_menu_item_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.init();
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
          '/welcome': (_) => const WelcomeScreen(),

          // Unified auth
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),

          // Customer main scaffold (home, search, cart, orders, profile)
          '/customer/home': (_) => const CustomerScaffold(),

          // Customer detail screens (pushed on top of scaffold)
          '/customer/search': (_) => const SearchScreen(),
          '/customer/menu': (_) => const StallMenuScreen(),
          '/customer/item': (_) => const FoodItemDetailScreen(),
          '/customer/cart': (_) => const CartScreen(),
          '/customer/order-tracking': (_) => const OrderTrackingScreen(),

          // Seller main scaffold (dashboard, orders, menu, settings)
          '/seller/home': (_) => const SellerScaffold(),

          // Seller detail screens (pushed on top of scaffold)
          '/seller/menu/add': (_) => const AddEditMenuItemScreen(),
        },
      ),
    );
  }
}
