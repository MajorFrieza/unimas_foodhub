import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/seller_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/stall_card.dart';

class StallListScreen extends StatefulWidget {
  const StallListScreen({super.key});

  @override
  State<StallListScreen> createState() => _StallListScreenState();
}

class _StallListScreenState extends State<StallListScreen> {
  final _db = DatabaseService();
  String _searchQuery = '';
  bool _showOpenOnly = false;

  @override
  Widget build(BuildContext context) {
    final customerName = context.select<AuthProvider, String>(
        (p) => p.customer?.name ?? '');

    return Scaffold(
      appBar: AppBar(
        title: const Text('UNIMAS FoodHub'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'My Orders',
            onPressed: () =>
                Navigator.of(context).pushNamed('/customer/orders'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: _confirmSignOut,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header greeting
          Container(
            width: double.infinity,
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${customerName.split(' ').first}! 👋',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'What would you like to eat today?',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 16),
                // Search bar
                TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search stalls...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filter chip
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const Text(
                  'Food Stalls',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                FilterChip(
                  label: const Text('Open Now'),
                  selected: _showOpenOnly,
                  onSelected: (v) => setState(() => _showOpenOnly = v),
                  selectedColor: AppColors.success.withValues(alpha: 0.15),
                  checkmarkColor: AppColors.success,
                  labelStyle: TextStyle(
                    color: _showOpenOnly
                        ? AppColors.success
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Stall list
          Expanded(
            child: StreamBuilder<List<SellerModel>>(
              stream: _db.sellersStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                var stalls = snapshot.data ?? [];

                // Apply filters
                if (_searchQuery.isNotEmpty) {
                  stalls = stalls
                      .where((s) =>
                          s.stallName
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()) ||
                          s.description
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()))
                      .toList();
                }
                if (_showOpenOnly) {
                  stalls = stalls.where((s) => s.isOpen).toList();
                }

                if (stalls.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.storefront_outlined,
                            size: 64, color: AppColors.textHint),
                        const SizedBox(height: 12),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No stalls match "$_searchQuery"'
                              : 'No stalls available right now',
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: stalls.length,
                  itemBuilder: (_, i) => StallCard(
                    seller: stalls[i],
                    onTap: () => Navigator.of(context).pushNamed(
                      '/customer/menu',
                      arguments: stalls[i],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().signOut();
              if (mounted) {
                Navigator.of(context)
                    .pushReplacementNamed('/role-selection');
              }
            },
            child: const Text('Sign Out',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
