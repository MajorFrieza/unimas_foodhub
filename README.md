# UNIMAS FoodHub

UNIMAS FoodHub is a Flutter app for discovering campus food stalls, placing
pickup orders, and letting sellers manage menus and order status. Firebase
Authentication and Realtime Database provide app identity and data storage.
Accounts, orders, menus, and customer ratings use Firebase Authentication and
Realtime Database. This version does not use Cloud Functions or require
Firebase Blaze billing.

## Local development

1. Install the Flutter SDK. Node.js, the Firebase CLI, and Java are only needed
   to run the optional Realtime Database rules tests.
2. Run `flutter pub get` from the repository root.
3. Run `flutter run` to launch the app on a configured device.
4. Run `flutter analyze` to check Dart code.
5. To test database rules, run `npm install` in `firebase-tests/`, then from
   the repository root run
   `firebase emulators:exec --only database --project demo-unimas-foodhub "npm test --prefix firebase-tests"`.

The app is configured for the Firebase project `unimas-foodhub`. Do not commit
service-account keys or other private credentials.

## Firebase Realtime Database rules

The Realtime Database policy is maintained in `database.rules.json`. If you
change the rules, install the Firebase CLI and authenticate with an account
authorized for the project, then deploy only the rules with:

```sh
firebase deploy --only database --project unimas-foodhub
```

This client-only configuration does not require enabling Blaze billing.
Realtime Database rules validate order ownership, item prices, status changes,
and rating eligibility. Because the app writes orders directly, a modified
client could still falsify the order total; preventing that requires trusted
server-side code such as Cloud Functions.

## Current feature scope

- Customer and seller email/password accounts
- Stall and menu discovery, favorites, cart, order tracking, and ratings
- Seller stall profile, menu, and order-status management
- Manual payment using a seller's displayed payment QR code; payment is not
  automatically verified or reconciled by the app
