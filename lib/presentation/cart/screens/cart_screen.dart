import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:riturasa/core/theme/riturasa_theme.dart';

/// Item model for the Cart / Shopping List
class CartItem {
  final String id;
  final String name;
  final String quantity;
  final String category;
  final String sourceRecipe;
  bool isCompleted;

  CartItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.category,
    required this.sourceRecipe,
    this.isCompleted = false,
  });
}

/// Cart (Shopping List) Screen conforming to nutrition_flutter_ui_5_screen_srs.md.
/// Closes the loop from Recipe recommendations -> Shopping -> Kitchen pantry.
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final List<CartItem> _items = [
    CartItem(
      id: '1',
      name: 'Fresh Palak (Spinach)',
      quantity: '2 bunches',
      category: 'Vegetables',
      sourceRecipe: 'Spinach Moong Dal',
    ),
    CartItem(
      id: '2',
      name: 'Yellow Moong Dal (Split)',
      quantity: '500 g',
      category: 'Protein & Staples',
      sourceRecipe: 'Spinach Moong Dal',
    ),
    CartItem(
      id: '3',
      name: 'Curry Leaves (Kadi Patta)',
      quantity: '1 bunch',
      category: 'Vegetables',
      sourceRecipe: 'Kadhi Pakora & Dal Tadka',
    ),
    CartItem(
      id: '4',
      name: 'Organic White Sesame Seeds (Til)',
      quantity: '250 g',
      category: 'Seeds & Superfoods',
      sourceRecipe: 'Til Ladoo & Luteal Seed Cycling',
      isCompleted: true,
    ),
    CartItem(
      id: '5',
      name: 'A2 Desi Cow Ghee',
      quantity: '500 ml',
      category: 'Dairy & Rasayanas',
      sourceRecipe: 'Ojas Vitality Bowl',
    ),
    CartItem(
      id: '6',
      name: 'Sprouted Ragi Flour (Finger Millet)',
      quantity: '1 kg',
      category: 'Protein & Staples',
      sourceRecipe: 'Ragi Malt & Porridge',
      isCompleted: true,
    ),
  ];

  void _toggleItem(CartItem item) {
    setState(() {
      item.isCompleted = !item.isCompleted;
    });
  }

  void _addNewItem(String name, String qty, String category) {
    if (name.trim().isEmpty) return;
    setState(() {
      _items.insert(
        0,
        CartItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name.trim(),
          quantity: qty.trim().isEmpty ? '1 item' : qty.trim(),
          category: category,
          sourceRecipe: 'Manual Entry',
        ),
      );
    });
  }

  void _showAddItemDialog(RituRasaThemeData theme) {
    final nameController = TextEditingController();
    final qtyController = TextEditingController();
    String selectedCategory = 'Vegetables';
    final categories = ['Vegetables', 'Protein & Staples', 'Seeds & Superfoods', 'Dairy & Rasayanas', 'Spices & Herbs'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                        labelText: 'Item Name (e.g. Tomatoes, Ashwagandha)',
                        labelStyle: GoogleFonts.outfit(color: theme.textSecondary, fontSize: 13),
                        filled: true,
                        fillColor: theme.surfaceContainer,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.cardBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
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
                          child: TextField(
                            controller: qtyController,
                            decoration: InputDecoration(
                              labelText: 'Qty (e.g. 500g, 2 bunches)',
                              labelStyle: GoogleFonts.outfit(color: theme.textSecondary, fontSize: 13),
                              filled: true,
                              fillColor: theme.surfaceContainer,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: theme.cardBorder),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: theme.cardBorder),
                              ),
                            ),
                            style: GoogleFonts.outfit(fontSize: 14, color: theme.textPrimary),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedCategory,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: 'Category',
                              labelStyle: GoogleFonts.outfit(color: theme.textSecondary, fontSize: 13),
                              filled: true,
                              fillColor: theme.surfaceContainer,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: theme.cardBorder),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: theme.cardBorder),
                              ),
                            ),
                            items: categories.map((c) {
                              return DropdownMenuItem(
                                value: c,
                                child: Text(
                                  c,
                                  style: GoogleFonts.outfit(fontSize: 13, color: theme.textPrimary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setModalState(() => selectedCategory = val);
                              }
                            },
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
                          _addNewItem(nameController.text, qtyController.text, selectedCategory);
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
      },
    );
  }

  void _transferToKitchen() {
    final completedItems = _items.where((i) => i.isCompleted).toList();
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

    setState(() {
      _items.removeWhere((i) => i.isCompleted);
    });

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

  @override
  Widget build(BuildContext context) {
    final theme = context.rituTheme;
    final pendingItems = _items.where((i) => !i.isCompleted).toList();
    final completedItems = _items.where((i) => i.isCompleted).toList();

    // Group pending items by category
    final Map<String, List<CartItem>> groupedPending = {};
    for (final item in pendingItems) {
      groupedPending.putIfAbsent(item.category, () => []).add(item);
    }

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

              // Grouped Pending Items
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
                for (final entry in groupedPending.entries) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, top: 4),
                    child: Text(
                      entry.key,
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
                    itemCount: entry.value.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, idx) {
                      final item = entry.value[idx];
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
                        onPressed: _transferToKitchen,
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
                      onPressed: _transferToKitchen,
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

  Widget _buildCartItemTile(RituRasaThemeData theme, CartItem item) {
    return GestureDetector(
      onTap: () => _toggleItem(item),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: item.isCompleted
              ? theme.cardBackground.withValues(alpha: 0.6)
              : theme.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: item.isCompleted ? theme.cardBorder.withValues(alpha: 0.6) : theme.cardBorder,
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
                color: item.isCompleted ? theme.navBarActivePill : Colors.white,
                border: Border.all(
                  color: item.isCompleted ? theme.navBarActivePill : theme.cardBorder,
                  width: 2,
                ),
              ),
              child: item.isCompleted
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
                      color: item.isCompleted ? theme.textMuted : theme.textPrimary,
                      decoration: item.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.quantity,
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
                          'Needed for: ${item.sourceRecipe}',
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
                setState(() {
                  _items.removeWhere((i) => i.id == item.id);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
