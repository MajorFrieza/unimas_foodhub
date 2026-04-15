import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/menu_item_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_text_field.dart';

class AddEditMenuItemScreen extends StatefulWidget {
  const AddEditMenuItemScreen({super.key});

  @override
  State<AddEditMenuItemScreen> createState() =>
      _AddEditMenuItemScreenState();
}

class _AddEditMenuItemScreenState extends State<AddEditMenuItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  String _selectedCategory = AppConstants.menuCategories[1]; // 'Rice' default
  bool _isAvailable = true;
  bool _isSaving = false;

  MenuItemModel? _existingItem;
  bool get _isEditing => _existingItem != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)!.settings.arguments;
    if (arg is MenuItemModel && _existingItem == null) {
      _existingItem = arg;
      _nameCtrl.text = arg.name;
      _descCtrl.text = arg.description;
      _priceCtrl.text = arg.price.toStringAsFixed(2);
      _selectedCategory = arg.category;
      _isAvailable = arg.isAvailable;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() => _isSaving = true);

    final uid = context.read<AuthProvider>().currentUserId;
    final db = DatabaseService();
    final price = double.parse(_priceCtrl.text.trim());

    try {
      if (_isEditing) {
        await db.updateMenuItem(uid, _existingItem!.id, {
          'name': _nameCtrl.text.trim(),
          'description': _descCtrl.text.trim(),
          'price': price,
          'category': _selectedCategory,
          'isAvailable': _isAvailable,
        });
      } else {
        final newItem = MenuItemModel(
          id: '',
          sellerId: uid,
          name: _nameCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          price: price,
          category: _selectedCategory,
          isAvailable: _isAvailable,
          createdAt: DateTime.now(),
        );
        await db.addMenuItem(uid, newItem);
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Item' : 'Add Menu Item'),
        backgroundColor: AppColors.primaryDark,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                  controller: _nameCtrl,
                  label: 'Item Name',
                  hint: 'e.g. Nasi Lemak',
                  prefixIcon: Icons.fastfood_outlined,
                  maxLength: AppConstants.maxMenuItemNameLength,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Item name is required' : null,
                ),
                const SizedBox(height: 14),

                CustomTextField(
                  controller: _descCtrl,
                  label: 'Description',
                  hint: 'Brief description of the item',
                  prefixIcon: Icons.description_outlined,
                  maxLines: 3,
                ),
                const SizedBox(height: 14),

                CustomTextField(
                  controller: _priceCtrl,
                  label: 'Price (RM)',
                  hint: '0.00',
                  prefixIcon: Icons.attach_money,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Price is required';
                    final price = double.tryParse(v);
                    if (price == null || price <= 0) {
                      return 'Enter a valid price';
                    }
                    if (price > AppConstants.maxMenuItemPrice) {
                      return 'Price too high';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Category picker
                const Text(
                  'Category',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: AppConstants.menuCategories
                      .where((c) => c != 'All')
                      .map((cat) {
                    final selected = _selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: selected,
                      onSelected: (_) =>
                          setState(() => _selectedCategory = cat),
                      selectedColor: AppColors.primaryDark,
                      labelStyle: TextStyle(
                        color: selected
                            ? Colors.white
                            : AppColors.textSecondary,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Availability toggle
                Card(
                  child: SwitchListTile(
                    value: _isAvailable,
                    onChanged: (v) => setState(() => _isAvailable = v),
                    activeThumbColor: AppColors.success,
                    title: const Text('Available for Order'),
                    subtitle: Text(
                      _isAvailable
                          ? 'Customers can order this item'
                          : 'Item is hidden from customers',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          _isEditing ? 'Save Changes' : 'Add to Menu',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
