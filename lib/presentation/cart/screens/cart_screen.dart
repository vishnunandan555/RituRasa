import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:riturasa/core/theme/riturasa_theme.dart';
import 'package:riturasa/domain/models/shopping_item.dart';
import 'package:riturasa/features/kitchen/kitchen_controller.dart';
import 'package:riturasa/features/shopping/shopping_controller.dart';

/// Cart (Shopping List) Screen conforming to nutrition_flutter_ui_5_screen_srs.md.
/// Closes the loop from Recipe recommendations -> Shopping -> Kitchen pantry.
class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  void _showAddItemDialog(RituRasaThemeExtension theme) {
    final nameController = TextEditingController();
    final qtyController = TextEditingController(text: '1');
    final unitController = TextEditingController(text: 'units');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardBackground,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: theme.cardBorder),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add to Shopping List',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: theme.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: theme.textSecondary),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Item Name (e.g. Tomatoes, Ghee, Palak)',
                    labelStyle: GoogleFonts.outfit(color: theme.textSecondary, fontSize: 13),
                    filled: true,
                    fillColor: theme.screenBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.cardBorder),
                    ),
                  ),
                  style: GoogleFonts.outfit(fontSize: 14, color: theme.textPrimary),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: TextField(
                        controller: qtyController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Qty',
                          labelStyle: GoogleFonts.outfit(color: theme.textSecondary, fontSize: 13),
                          filled: true,
                          fillColor: theme.screenBackground,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: theme.cardBorder),
                          ),
                        ),
                        style: GoogleFonts.outfit(fontSize: 14, color: theme.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 5,
                      child: TextField(
                        controller: unitController,
                        decoration: InputDecoration(
                          labelText: 'Unit (g, kg, ml, bunches)',
                          labelStyle: GoogleFonts.outfit(color: theme.textSecondary, fontSize: 13),
                          filled: true,
                          fillColor: theme.screenBackground,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: theme.cardBorder),
                          ),
                        ),
                        style: GoogleFonts.outfit(fontSize: 14, color: theme.textPrimary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.navBarActivePill,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      final name = nameController.text.trim();
                      final qty = double.tryParse(qtyController.text.trim()) ?? 1.0;
                      final unit = unitController.text.trim().isEmpty ? 'units' : unitController.text.trim();
                      if (name.isNotEmpty) {
                        ref.read(shoppingNotifierProvider.notifier).addItem(
                              foodId: 'food_${DateTime.now().millisecondsSinceEpoch}',
                              name: name,
                              quantity: qty,
                              unit: unit,
                            );
                      }
                      Navigator.pop(ctx);
                    },
                    child: Text(
                      'Add to Cart',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _transferToKitchen(List<ShoppingListItem> completedItems) async {
    if (completedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Check off purchased items first to add them to your kitchen!',
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
          ),
          backgroundColor: const Color(0xFF1E293B),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    for (final item in completedItems) {
      await ref.read(kitchenNotifierProvider.notifier).addItem(
            foodId: item.foodId.isNotEmpty ? item.foodId : 'k_food_${DateTime.now().millisecondsSinceEpoch}',
            foodName: item.name,
            quantity: item.quantity,
            unit: item.unit,
          );
    }

    await ref.read(shoppingNotifierProvider.notifier).clearChecked();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Added ${completedItems.length} purchased items to your Kitchen pantry!',
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1E293B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.rituTheme;
    final shoppingState = ref.watch(shoppingNotifierProvider);
    final items = shoppingState.items;

    final pendingItems = items.where((i) => !i.isChecked).toList();
    final completedItems = items.where((i) => i.isChecked).toList();

    return Scaffold(
      backgroundColor: theme.screenBackground,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: theme.screenPadding,
            right: theme.screenPadding,
            top: 16,
            bottom: 110,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Shopping List',
                          style: theme.screenTitleStyle,
                        ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0),
                        const SizedBox(height: 3),
                        Text(
                          '${pendingItems.length} items left · Generated from recipes',
                          style: theme.screenSubtitleStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ).animate().fadeIn(duration: 350.ms),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddItemDialog(theme),
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(
                      'Add Item',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.navBarActivePill,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Summary Banner Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardBackground,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: theme.cardBorder, width: 1.2),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: theme.navBarActivePill,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pendingItems.isEmpty
                                ? 'All groceries purchased!'
                                : '${pendingItems.length} Items to Purchase',
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: theme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Missing ingredients for recommended recipes',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: theme.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 20),

              // Pending Items
              if (pendingItems.isEmpty && completedItems.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(Icons.checklist_rtl_rounded, size: 48, color: theme.textMuted),
                        const SizedBox(height: 12),
                        Text(
                          'Your cart is empty',
                          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: theme.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Add missing ingredients from recommended recipes or tap + Add Item.',
                          style: GoogleFonts.outfit(fontSize: 13, color: theme.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                if (pendingItems.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, top: 4),
                    child: Text(
                      'Pantry Items to Buy (${pendingItems.length})',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: theme.textSecondary,
                      ),
                    ),
                  ),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: pendingItems.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, idx) {
                      final item = pendingItems[idx];
                      return _buildCartItemTile(theme, item);
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Completed Section
                if (completedItems.isNotEmpty) ...[
                  const Divider(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Completed (${completedItems.length})',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: theme.textMuted,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () => _transferToKitchen(completedItems),
                        icon: const Icon(Icons.input_rounded, size: 15),
                        label: Text(
                          'Move to Kitchen',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF10B981),
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: completedItems.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, idx) {
                      final item = completedItems[idx];
                      return _buildCartItemTile(theme, item);
                    },
                  ),

                  const SizedBox(height: 20),

                  // Cart -> Kitchen Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _transferToKitchen(completedItems),
                      icon: const Icon(Icons.kitchen_outlined, size: 18),
                      label: Text(
                        'Add purchased items to Kitchen',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartItemTile(RituRasaThemeExtension theme, ShoppingListItem item) {
    final qtyDisplay = item.quantity % 1 == 0 ? item.quantity.toInt().toString() : item.quantity.toStringAsFixed(1);

    return GestureDetector(
      onTap: () {
        ref.read(shoppingNotifierProvider.notifier).toggleChecked(item.id, !item.isChecked);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: item.isChecked
              ? theme.cardBackground.withValues(alpha: 0.6)
              : theme.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: item.isChecked ? theme.cardBorder.withValues(alpha: 0.6) : theme.cardBorder,
            width: 1.1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.isChecked ? theme.navBarActivePill : Colors.white,
                border: Border.all(
                  color: item.isChecked ? theme.navBarActivePill : theme.cardBorder,
                  width: 2,
                ),
              ),
              child: item.isChecked
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: item.isChecked ? theme.textMuted : theme.textPrimary,
                      decoration: item.isChecked ? TextDecoration.lineThrough : TextDecoration.none,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          '$qtyDisplay ${item.unit}',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '  •  ',
                        style: GoogleFonts.outfit(fontSize: 11, color: theme.textMuted),
                      ),
                      Flexible(
                        child: Text(
                          item.sourceRecipeIds.isNotEmpty ? 'Needed for Recipe' : 'Kitchen Grocery',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: theme.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: theme.textMuted, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              onPressed: () {
                ref.read(shoppingNotifierProvider.notifier).deleteItem(item.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
