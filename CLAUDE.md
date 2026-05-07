# UNIMAS FoodHub — Claude Instructions

## Project Overview
Flutter food ordering app for UNIMAS campus (FYP project). Pickup-based ordering system with two user roles: customer and seller.

## Tech Stack
- **Flutter** (Dart) — mobile only, Android
- **Firebase Realtime Database** — all data storage (NOT Firestore)
- **Firebase Auth** — email/password authentication
- **Firebase Storage** — not used; images stored as base64 strings in RTDB
- **Provider** — state management

## Key Conventions
- Use `.withValues(alpha: x)` not `.withOpacity(x)`
- Use `activeThumbColor` not `thumbColor` on Switch widgets
- No unused imports or variables
- No comments unless the reason is non-obvious
- Default `BoxFit` for images is `BoxFit.cover`

## Project Structure
- `lib/models/` — data models (UserModel, SellerModel, OrderModel, MenuItemModel)
- `lib/providers/` — AuthProvider (only provider in use)
- `lib/services/` — AuthService, DatabaseService
- `lib/screens/` — all UI screens, split into `auth/`, `customer/`, `seller/`
- `lib/utils/` — AppColors, constants, ImageHelper
- `assets/images/` — welcome_bg.jpg, logo.png

## Image Handling
Images (stall photos, menu items, QR codes) are stored as base64 strings in Firebase.
Always use `ImageHelper.buildImage()` — never `Image.network()` directly — as it handles both base64 and HTTP URLs.

## Firebase Structure
- `/users/{uid}` — customer profiles
- `/sellers/{uid}` — seller profiles (includes operatingHours, paymentQrUrl)
- `/orders/{orderId}` — orders (sellerId, customerId indexed)
- `/menuItems/{sellerId}/{itemId}` — menu items per seller

## Order Flow
Pending → Confirmed → Preparing → Ready → Completed (or Cancelled)
Seller drives all status changes. Customer tracks in real-time via StreamBuilder.

## Colors
- Primary (maroon): `AppColors.primary` = `#8B1538`
- Accent (orange): `AppColors.accent` = `#E8530A`
- Gold (popular badge): `AppColors.popular` = `#E8A020`

## User
Hafizh — UNIMAS software engineering student, building this as FYP.
