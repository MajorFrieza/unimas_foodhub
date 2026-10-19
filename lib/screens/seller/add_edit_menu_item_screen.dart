import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/menu_item_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../utils/image_helper.dart';
import '../../widgets/custom_text_field.dart';

class AddEditMenuItemScreen extends StatefulWidget {
  const AddEditMenuItemScreen({super.key});

  @override
  State<AddEditMenuItemScreen> createState() => _AddEditMenuItemScreenState();
}

class _AddEditMenuItemScreenState extends State<AddEditMenuItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _prepTimeCtrl = TextEditingController();
  final _caloriesCtrl = TextEditingController();

  String? _imageData;
  String _selectedCategory = AppConstants.menuCategories[1];
  bool _isAvailable = true;
  bool _isPopular = false;
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
      _isPopular = arg.isPopular;
      _prepTimeCtrl.text = arg.prepTime > 0 ? '${arg.prepTime}' : '';
      _caloriesCtrl.text = arg.calories > 0 ? '${arg.calories}' : '';
      _imageData = arg.imageUrl;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _prepTimeCtrl.dispose();
    _caloriesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);

    final uid = context.read<AuthProvider>().currentUserId;
    final db = DatabaseService();
    final price = double.parse(_priceCtrl.text.trim());
    final prepTime = int.tryParse(_prepTimeCtrl.text.trim()) ?? 15;
    final calories = int.tryParse(_caloriesCtrl.text.trim()) ?? 0;

    try {
      final imageUrl = _imageData;

      if (_isEditing) {
        await db.updateMenuItem(uid, _existingItem!.id, {
          'stallName': context.read<AuthProvider>().seller?.stallName ?? '',
          'name': _nameCtrl.text.trim(),
          'description': _descCtrl.text.trim(),
          'price': price,
          'category': _selectedCategory,
          'isAvailable': _isAvailable,
          'isPopular': _isPopular,
          'prepTime': prepTime,
          'calories': calories,
          'imageUrl': imageUrl,
        });
      } else {
        final newItem = MenuItemModel(
          id: '',
          sellerId: uid,
          stallName: context.read<AuthProvider>().seller?.stallName ?? '',
          name: _nameCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          price: price,
          category: _selectedCategory,
          isAvailable: _isAvailable,
          isPopular: _isPopular,
          prepTime: prepTime,
          calories: calories,
          imageUrl: imageUrl,
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _isEditing ? 'Edit Item' : 'Add Menu Item',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: _isSaving ? null : _save,
              child: const Text(
                'Save',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image picker
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: _imageData != null
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              ImageHelper.buildImage(
                                _imageData,
                                placeholder: _photoPlaceholder(),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _imageData = null),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.black
                                          .withValues(alpha: 0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close,
                                        color: Colors.white, size: 16),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Tap to change',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 11),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : _photoPlaceholder(),
                  ),
                ),
                const SizedBox(height: 20),

                // Basic info section
                _sectionLabel('Basic Information'),
                const SizedBox(height: 12),

                CustomTextField(
                  controller: _nameCtrl,
                  label: 'Item Name',
                  hint: 'e.g. Nasi Lemak Special',
                  prefixIcon: Icons.fastfood_outlined,
                  maxLength: AppConstants.maxMenuItemNameLength,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Item name is required' : null,
                ),
                const SizedBox(height: 14),

                CustomTextField(
                  controller: _descCtrl,
                  label: 'Description',
                  hint: 'Describe the item (ingredients, taste, etc.)',
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
                    final p = double.tryParse(v);
                    if (p == null || p <= 0) return 'Enter a valid price';
                    if (p > AppConstants.maxMenuItemPrice) return 'Price too high';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Details section
                _sectionLabel('Details'),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _prepTimeCtrl,
                        label: 'Prep Time (min)',
                        hint: '15',
                        prefixIcon: Icons.timer_outlined,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        controller: _caloriesCtrl,
                        label: 'Calories (kcal)',
                        hint: '0',
                        prefixIcon: Icons.local_fire_department_outlined,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Category section
                _sectionLabel('Category'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AppConstants.menuCategories
                      .where((c) => c != 'All')
                      .map((cat) {
                    final selected = _selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : AppColors.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: selected
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Toggles section
                _sectionLabel('Options'),
                const SizedBox(height: 12),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: _isAvailable,
                        onChanged: (v) => setState(() => _isAvailable = v),
                        activeThumbColor: AppColors.success,
                        activeTrackColor:
                            AppColors.success.withValues(alpha: 0.3),
                        title: const Text(
                          'Available for Order',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          _isAvailable
                              ? 'Customers can order this item'
                              : 'Item is hidden from customers',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      SwitchListTile(
                        value: _isPopular,
                        onChanged: (v) => setState(() => _isPopular = v),
                        activeThumbColor: AppColors.popular,
                        activeTrackColor:
                            AppColors.popular.withValues(alpha: 0.3),
                        title: const Text(
                          'Mark as Popular',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        subtitle: const Text(
                          'Shows a "Popular" badge on this item',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
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
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final data = await ImageHelper.pickFromGallery();
    if (data != null) setState(() => _imageData = data);
  }

  Widget _photoPlaceholder() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add_photo_alternate_outlined,
                color: AppColors.primary, size: 26),
          ),
          const SizedBox(height: 10),
          const Text(
            'Add Photo',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tap to pick from gallery',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      );

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      );
}
