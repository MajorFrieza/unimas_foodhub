import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();

  int _step = 1;
  bool _isCustomer = true;

  // Step 1 fields
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  // Step 2 fields
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _stallNameCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _stallNameCtrl.dispose();
    _descriptionCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  void _goToStep2() {
    if (_formKey1.currentState!.validate()) {
      setState(() => _step = 2);
    }
  }

  Future<void> _createAccount() async {
    if (!_formKey2.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    bool ok;
    if (_isCustomer) {
      ok = await auth.registerCustomer(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        phone: _phoneCtrl.text.trim(),
      );
    } else {
      ok = await auth.registerSeller(
        stallName: _stallNameCtrl.text.trim(),
        ownerName: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        phone: _phoneCtrl.text.trim(),
        description: _descriptionCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
      );
    }
    if (!mounted) return;
    if (ok) {
      if (auth.isCustomer) {
        Navigator.pushReplacementNamed(context, '/customer/home');
      } else {
        Navigator.pushReplacementNamed(context, '/seller/home');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Registration failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        context.watch<AuthProvider>().status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Back button
              IconButton(
                onPressed: () {
                  if (_step == 2) {
                    setState(() => _step = 1);
                  } else {
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(height: 20),

              // Step indicator
              Row(
                children: [
                  _StepDot(active: _step >= 1, done: _step > 1, number: 1),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: _step > 1 ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  _StepDot(active: _step >= 2, done: false, number: 2),
                ],
              ),
              const SizedBox(height: 28),

              const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Fill in your details to get started',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),

              if (_step == 1) _buildStep1() else _buildStep2(isLoading),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Form(
      key: _formKey1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Role selector
          const Text(
            'I want to',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _RoleCard(
                  icon: Icons.person_outline,
                  label: 'Order Food',
                  selected: _isCustomer,
                  onTap: () => setState(() => _isCustomer = true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _RoleCard(
                  icon: Icons.storefront_outlined,
                  label: 'Sell Food',
                  selected: !_isCustomer,
                  onTap: () => setState(() => _isCustomer = false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          _fieldLabel('Full Name'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: _inputDecoration('Your full name'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
          ),
          const SizedBox(height: 16),

          _fieldLabel('Email'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: _inputDecoration('your.email@unimas.my'),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Enter your email';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 16),

          _fieldLabel('Phone Number'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: _inputDecoration('+60123456789'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Enter your phone' : null,
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _goToStep2,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Already have an account? ',
                style: TextStyle(
                    fontSize: 14, color: AppColors.textSecondary),
              ),
              GestureDetector(
                onTap: () =>
                    Navigator.pushReplacementNamed(context, '/login'),
                child: const Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStep2(bool isLoading) {
    return Form(
      key: _formKey2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Seller-only stall fields
          if (!_isCustomer) ...[
            _fieldLabel('Stall Name'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _stallNameCtrl,
              decoration: _inputDecoration('e.g. Warung Mak Cik'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter stall name' : null,
            ),
            const SizedBox(height: 16),
            _fieldLabel('Description'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionCtrl,
              maxLines: 3,
              decoration: _inputDecoration('Describe your stall...'),
            ),
            const SizedBox(height: 16),
            _fieldLabel('Location'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _locationCtrl,
              decoration: _inputDecoration('e.g. Block A, UNIMAS'),
            ),
            const SizedBox(height: 16),
          ],

          _fieldLabel('Password'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordCtrl,
            obscureText: _obscurePassword,
            decoration: _inputDecoration('Create a password').copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Enter a password';
              if (v.length < 6) return 'Minimum 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 16),

          _fieldLabel('Confirm Password'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _confirmPasswordCtrl,
            obscureText: _obscureConfirm,
            decoration: _inputDecoration('Re-enter your password').copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Confirm your password';
              if (v != _passwordCtrl.text) return 'Passwords do not match';
              return null;
            },
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isLoading ? null : _createAccount,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Text(
                      'Create Account',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      );

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF8F8F8),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final bool active;
  final bool done;
  final int number;

  const _StepDot(
      {required this.active, required this.done, required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.border,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: done
            ? const Icon(Icons.check, color: Colors.white, size: 16)
            : Text(
                '$number',
                style: TextStyle(
                  color: active ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                size: 28,
                color: selected
                    ? AppColors.primary
                    : AppColors.textSecondary),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.normal,
                color: selected
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
