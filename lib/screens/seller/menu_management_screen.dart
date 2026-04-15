import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/menu_item_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../utils/app_colors.dart';

class MenuManagementScreen extends StatelessWidget {
  const MenuManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().currentUserId;
    final db = DatabaseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Management'),
        backgroundColor: AppColors.primaryDark,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed(
          '/seller/menu/add',
          arguments: const <String, dynamic>{},
        ),
        backgroundColor: AppColors.primaryDark,
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
      body: StreamBuilder<List<MenuItemModel>>(
        stream: db.menuItemsStream(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryDark),
            );
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.restaurant_menu,
                      size: 72, color: AppColors.textHint),
                  SizedBox(height: 16),
                  Text(
                    'No menu items yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap + Add Item to create your first menu item',
                    style: TextStyle(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (_, i) => _MenuItemTile(
              item: items[i],
              sellerId: uid,
              db: db,
            ),
          );
        },
      ),
    );
  }
}

class _MenuItemTile extends StatelessWidget {
  final MenuItemModel item;
  final String sellerId;
  final DatabaseService db;

  const _MenuItemTile({
    required this.item,
    required this.sellerId,
    required this.db,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 52,
            height: 52,
            color: AppColors.primary.withValues(alpha: 0.1),
            child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                ? Image.network(item.imageUrl!, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                        Icons.fastfood,
                        color: AppColors.primary))
                : const Icon(Icons.fastfood, color: AppColors.primary),
          ),
        ),
        title: Text(
          item.name,
          style: theme.textTheme.titleMedium!.copyWith(
            decoration: item.isAvailable
                ? null
                : TextDecoration.lineThrough,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RM ${item.price.toStringAsFixed(2)}  ·  ${item.category}',
              style: theme.textTheme.bodySmall!
                  .copyWith(color: AppColors.primary),
            ),
            if (!item.isAvailable)
              const Text(
                'Unavailable',
                style: TextStyle(
                    fontSize: 11,
                    color: AppColors.error,
                    fontWeight: FontWeight.w500),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Availability toggle
            Switch(
              value: item.isAvailable,
              onChanged: (v) =>
                  db.toggleMenuItemAvailability(sellerId, item.id, v),
              activeThumbColor: AppColors.success,
            ),
            // More options
            PopupMenuButton<String>(
              onSelected: (action) =>
                  _handleAction(action, context),
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline,
                          size: 18, color: AppColors.error),
                      SizedBox(width: 8),
                      Text('Delete',
                          style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleAction(String action, BuildContext context) {
    if (action == 'edit') {
      Navigator.of(context).pushNamed(
        '/seller/menu/add',
        arguments: item,
      );
    } else if (action == 'delete') {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Delete Item'),
          content: Text('Delete "${item.name}" from your menu?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                db.deleteMenuItem(sellerId, item.id);
                Navigator.pop(context);
              },
              child: const Text('Delete',
                  style: TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      );
    }
  }
}
