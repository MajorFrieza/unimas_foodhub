import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/user_model.dart';
import '../models/seller_model.dart';
import '../utils/constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ─── Customer Registration ───────────────────────────────────────────────

  Future<UserModel> registerCustomer({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? matrixNo,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = UserModel(
      uid: credential.user!.uid,
      name: name,
      email: email,
      phone: phone,
      role: AppConstants.roleCustomer,
      matrixNo: matrixNo,
      createdAt: DateTime.now(),
    );

    await _db
        .ref('${AppConstants.usersPath}/${user.uid}')
        .set(user.toMap());

    await credential.user!.updateDisplayName(name);
    return user;
  }

  // ─── Seller Registration ─────────────────────────────────────────────────

  Future<SellerModel> registerSeller({
    required String stallName,
    required String ownerName,
    required String email,
    required String password,
    required String phone,
    required String description,
    String? location,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final seller = SellerModel(
      uid: credential.user!.uid,
      stallName: stallName,
      ownerName: ownerName,
      email: email,
      phone: phone,
      description: description,
      isOpen: false,
      location: location,
      createdAt: DateTime.now(),
    );

    await _db
        .ref('${AppConstants.sellersPath}/${seller.uid}')
        .set(seller.toMap());

    await credential.user!.updateDisplayName(stallName);
    return seller;
  }

  // ─── Login ────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;

    // Check if customer
    final customerSnapshot =
        await _db.ref('${AppConstants.usersPath}/$uid').get();
    if (customerSnapshot.exists) {
      final user = UserModel.fromMap(
          uid, customerSnapshot.value as Map<dynamic, dynamic>);
      return {'role': AppConstants.roleCustomer, 'data': user};
    }

    // Check if seller
    final sellerSnapshot =
        await _db.ref('${AppConstants.sellersPath}/$uid').get();
    if (sellerSnapshot.exists) {
      final seller = SellerModel.fromMap(
          uid, sellerSnapshot.value as Map<dynamic, dynamic>);
      return {'role': AppConstants.roleSeller, 'data': seller};
    }

    throw Exception('User profile not found. Please contact support.');
  }

  // ─── Fetch Profile ────────────────────────────────────────────────────────

  Future<UserModel?> fetchCustomerProfile(String uid) async {
    final snapshot = await _db.ref('${AppConstants.usersPath}/$uid').get();
    if (!snapshot.exists) return null;
    return UserModel.fromMap(uid, snapshot.value as Map<dynamic, dynamic>);
  }

  Future<SellerModel?> fetchSellerProfile(String uid) async {
    final snapshot = await _db.ref('${AppConstants.sellersPath}/$uid').get();
    if (!snapshot.exists) return null;
    return SellerModel.fromMap(uid, snapshot.value as Map<dynamic, dynamic>);
  }

  // ─── Sign Out ─────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ─── Password Reset ───────────────────────────────────────────────────────

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
