import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';

class SellerSettingsScreen extends StatelessWidget {
  const SellerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final seller = auth.seller;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile card
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  // Avatar with stall initial
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primary, AppColors.primaryDark],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        seller?.stallName.isNotEmpty == true
                            ? seller!.stallName[0].toUpperCase()
                            : 'S',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    seller?.stallName ?? 'My Stall',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    seller?.email ?? '',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Seller',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (seller?.rating != null && seller!.rating > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.popular.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star,
                                  size: 13, color: AppColors.popular),
                              const SizedBox(width: 4),
                              Text(
                                seller.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.popular,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Stall info section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.store_outlined,
                    label: 'Stall Name',
                    value: seller?.stallName ?? '—',
                  ),
                  const Divider(height: 1),
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Location',
                    value: seller?.location ?? '—',
                  ),
                  const Divider(height: 1),
                  _InfoRow(
                    icon: Icons.restaurant_outlined,
                    label: 'Cuisine Type',
                    value: seller?.cuisineType ?? '—',
                  ),
                  const Divider(height: 1),
                  _InfoRow(
                    icon: Icons.schedule_outlined,
                    label: 'Open Until',
                    value: seller?.openUntil ?? '—',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Account section
            const _SectionHeader(title: 'Account'),
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _MenuRow(
                    icon: Icons.edit_outlined,
                    label: 'Edit Stall Profile',
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 56),
                  _MenuRow(
                    icon: Icons.lock_outline,
                    label: 'Change Password',
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 56),
                  _MenuRow(
                    icon: Icons.phone_outlined,
                    label: 'Contact Number',
                    value: seller?.phone ?? 'Not set',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Preferences section
            const _SectionHeader(title: 'Preferences'),
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _MenuRow(
                    icon: Icons.notifications_outlined,
                    label: 'Order Notifications',
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 56),
                  _MenuRow(
                    icon: Icons.schedule_outlined,
                    label: 'Operating Hours',
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 56),
                  _MenuRow(
                    icon: Icons.payments_outlined,
                    label: 'Payment Methods',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Support section
            const _SectionHeader(title: 'Support'),
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _MenuRow(
                    icon: Icons.help_outline,
                    label: 'Help & Support',
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 56),
                  _MenuRow(
                    icon: Icons.policy_outlined,
                    label: 'Terms & Privacy',
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 56),
                  _MenuRow(
                    icon: Icons.info_outline,
                    label: 'About FoodHub',
                    value: 'v1.0.0',
                    onTap: () {},
                    showChevron: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Log out
            Container(
              color: Colors.white,
              child: _MenuRow(
                icon: Icons.logout,
                label: 'Log Out',
                iconColor: AppColors.error,
                labelColor: AppColors.error,
                showChevron: false,
                onTap: () => _confirmLogout(context, auth),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Out?'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await auth.signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/welcome', (route) => false);
              }
            },
            child: const Text('Log Out',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textHint)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.textPrimary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback onTap;
  final Color iconColor;
  final Color labelColor;
  final bool showChevron;

  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.value,
    this.iconColor = AppColors.textSecondary,
    this.labelColor = AppColors.textPrimary,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: iconColor),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: labelColor,
        ),
      ),
      trailing: value != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(value!,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary)),
                if (showChevron) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right,
                      color: AppColors.textHint, size: 20),
                ],
              ],
            )
          : showChevron
              ? const Icon(Icons.chevron_right,
                  color: AppColors.textHint, size: 20)
              : null,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
    );
  }
}
