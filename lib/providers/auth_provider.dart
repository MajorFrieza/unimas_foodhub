import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/seller_model.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;
  UserModel? _customer;
  SellerModel? _seller;
  String? _role;

  // Prevents _onAuthStateChanged from racing with login/register calls
  bool _handlingAuthManually = false;

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  UserModel? get customer => _customer;
  SellerModel? get seller => _seller;
  String? get role => _role;

  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isCustomer => _role == AppConstants.roleCustomer;
  bool get isSeller => _role == AppConstants.roleSeller;
  String get currentUserId => _authService.currentUser?.uid ?? '';
  String get currentUserName {
    if (isCustomer) return _customer?.name ?? '';
    if (isSeller) return _seller?.stallName ?? '';
    return '';
  }

  AuthProvider() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    // Skip if login/register is already handling this auth state change
    if (_handlingAuthManually) return;

    if (user == null) {
      _status = AuthStatus.unauthenticated;
      _customer = null;
      _seller = null;
      _role = null;
      notifyListeners();
      return;
    }

    _status = AuthStatus.loading;
    notifyListeners();

    try {
      // Try customer profile first
      final customerProfile = await _authService
          .fetchCustomerProfile(user.uid)
          .timeout(const Duration(seconds: 10));
      if (customerProfile != null) {
        _customer = customerProfile;
        _role = AppConstants.roleCustomer;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return;
      }

      // Try seller profile
      final sellerProfile = await _authService
          .fetchSellerProfile(user.uid)
          .timeout(const Duration(seconds: 10));
      if (sellerProfile != null) {
        _seller = sellerProfile;
        _role = AppConstants.roleSeller;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return;
      }

      // Profile not found — sign out
      await _authService.signOut();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Connection timed out. Check your internet and try again.';
      notifyListeners();
    }
  }

  // ─── Register Customer ────────────────────────────────────────────────────

  Future<bool> registerCustomer({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? matrixNo,
  }) async {
    _handlingAuthManually = true;
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _customer = await _authService.registerCustomer(
        name: name,
        email: email,
        password: password,
        phone: phone,
        matrixNo: matrixNo,
      );
      _role = AppConstants.roleCustomer;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _authErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _handlingAuthManually = false;
    }
  }

  // ─── Register Seller ──────────────────────────────────────────────────────

  Future<bool> registerSeller({
    required String stallName,
    required String ownerName,
    required String email,
    required String password,
    required String phone,
    required String description,
    String? location,
  }) async {
    _handlingAuthManually = true;
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _seller = await _authService.registerSeller(
        stallName: stallName,
        ownerName: ownerName,
        email: email,
        password: password,
        phone: phone,
        description: description,
        location: location,
      );
      _role = AppConstants.roleSeller;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _authErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _handlingAuthManually = false;
    }
  }

  // ─── Login ────────────────────────────────────────────────────────────────

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _handlingAuthManually = true;
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService
          .login(email: email, password: password)
          .timeout(const Duration(seconds: 15));
      _role = result['role'] as String;
      if (_role == AppConstants.roleCustomer) {
        _customer = result['data'] as UserModel;
      } else {
        _seller = result['data'] as SellerModel;
      }
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _authErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Connection timed out. Check your internet and try again.';
      notifyListeners();
      return false;
    } finally {
      _handlingAuthManually = false;
    }
  }

  // ─── Sign Out ─────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await _authService.signOut();
  }

  // ─── Update seller open status locally ───────────────────────────────────

  void updateSellerOpenStatus(bool isOpen) {
    if (_seller != null) {
      _seller = _seller!.copyWith(isOpen: isOpen);
      notifyListeners();
    }
  }

  void updateCustomerLocally({String? name, String? phone}) {
    if (_customer != null) {
      _customer = _customer!.copyWith(name: name, phone: phone);
      notifyListeners();
    }
  }

  void updateSellerLocally({
    String? stallName,
    String? description,
    String? location,
    String? phone,
    String? cuisineType,
    String? imageUrl,
    String? openFrom,
    String? openUntil,
  }) {
    if (_seller != null) {
      _seller = _seller!.copyWith(
        stallName: stallName,
        description: description,
        location: location,
        phone: phone,
        cuisineType: cuisineType,
        imageUrl: imageUrl,
        openFrom: openFrom,
        openUntil: openUntil,
      );
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _authErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
