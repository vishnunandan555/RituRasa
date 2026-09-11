import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:riturasa/core/theme/riturasa_theme.dart';
import 'package:riturasa/presentation/kitchen/widgets/add_food_dialog.dart';

class KitchenFoodItem {
  final String id;
  final String name;
  int amount;
  final String unit;
  final String category;
  final String nutrientHighlight;
  final IconData icon;

  KitchenFoodItem({
    required this.id,
    required this.name,
    required this.amount,
    required this.unit,
    required this.category,
    required this.nutrientHighlight,
    required this.icon,
  });
}

/// Kitchen & Pantry Screen
/// Central inventory differentiator. Tracks available food items at home,
/// calculates smart kitchen nutrient summaries, and feeds the recommendation engine.
class KitchenScreen extends StatefulWidget {
  const KitchenScreen({super.key});

  @override
  State<KitchenScreen> createState() => _KitchenScreenState();
}

class _KitchenScreenState extends State<KitchenScreen> {
  int _selectedCategoryIndex = 0;
  final List<String> _categories = [
    'All',
    'Vegetables',
    'Protein & Staples',
    'Seeds & Superfoods',
    'Dairy & Healthy Fats',
  ];

  final List<KitchenFoodItem> _items = [
    KitchenFoodItem(
      id: '1',
      name: 'Fresh Spinach (Palak)',
      amount: 2,
      unit: 'bunches',
      category: 'Vegetables',
      nutrientHighlight: 'Iron · Folate · Vitamin C',
      icon: Icons.eco_rounded,
    ),
    KitchenFoodItem(
      id: '2',
      name: 'Yellow Moong Dal',
      amount: 500,
      unit: 'g',
      category: 'Protein & Staples',
      nutrientHighlight: 'Bioavailable Protein · Fiber',
      icon: Icons.grain_rounded,
    ),
    KitchenFoodItem(
      id: '3',
      name: 'Finger Millet (Ragi Flour)',
      amount: 1000,
      unit: 'g',
      category: 'Protein & Staples',
      nutrientHighlight: 'Calcium · Bioavailable Iron',
      icon: Icons.breakfast_dining_rounded,
    ),
    KitchenFoodItem(
      id: '4',
      name: 'Sesame Seeds (Til)',
      amount: 200,
      unit: 'g',
      category: 'Seeds & Superfoods',
      nutrientHighlight: 'Zinc · Healthy Lipids',
      icon: Icons.scatter_plot_rounded,
    ),
    KitchenFoodItem(
      id: '5',
      name: 'A2 Desi Cow Ghee',
      amount: 450,
      unit: 'ml',
      category: 'Dairy & Healthy Fats',
      nutrientHighlight: 'Ojas Builder · Fat Soluble Vit',
      icon: Icons.water_drop_rounded,
    ),
    KitchenFoodItem(
      id: '6',
      name: 'Organic Tomatoes',
      amount: 5,
      unit: 'pcs',
      category: 'Vegetables',
      nutrientHighlight: 'Lycopene · Vitamin C',
      icon: Icons.restaurant_menu_rounded,
    ),
  ];

  void _openAddFoodDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddFoodDialog(
        onAdd: (name, qtyStr, category, nutrientTag) {
          int parsedAmount = 1;
          String unit = qtyStr;
          final match = RegExp(r'^(\d+)\s*(.*)$').firstMatch(qtyStr.trim());
          if (match != null) {
            parsedAmount = int.tryParse(match.group(1) ?? '1') ?? 1;
            unit = match.group(2)?.trim().isNotEmpty == true ? match.group(2)!.trim() : 'item';
          }

          setState(() {
            _items.insert(
              0,
              KitchenFoodItem(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: name,
                amount: parsedAmount,
                unit: unit,
                category: category,
                nutrientHighlight: nutrientTag,
                icon: Icons.check_circle_outline,
              ),
            );
          });
        },
      ),
    );
  }

  void _adjustQuantity(KitchenFoodItem item, int delta) {
    setState(() {
      item.amount += delta;
      if (item.amount <= 0) {
        _items.removeWhere((i) => i.id == item.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.rituTheme;

    final filteredItems = _selectedCategoryIndex == 0
        ? _items
        : _items.where((i) => i.category == _categories[_selectedCategoryIndex]).toList();

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
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Kitchen',
                          style: theme.screenTitleStyle,
                        ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0),
                        const SizedBox(height: 3),
                        Text(
                          'What do you have at home?',
                          style: theme.screenSubtitleStyle,
                        ).animate().fadeIn(duration: 350.ms),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _openAddFoodDialog,
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(
                      'Add Food',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.navBarActivePill,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Smart Kitchen Summary Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardBackground,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: theme.cardBorder, width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: Color(0xFF10B981),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Smart Kitchen Summary',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: theme.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Your kitchen currently has 3 iron-rich foods · 2 protein sources · 2 high-calcium staples available for cycle-tailored cooking.',
                      style: GoogleFonts.outfit(
                        fontSize: 12.5,
                        color: theme.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 18),

              // Category Selector
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final isSelected = index == _selectedCategoryIndex;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategoryIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected ? theme.chipSelectedBg : theme.chipUnselectedBg,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: Text(
                            _categories[index],
                            style: GoogleFonts.outfit(
                              fontSize: 12.5,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? theme.chipSelectedText : theme.chipUnselectedText,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Inventory Items or Empty State
              if (filteredItems.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(Icons.kitchen_outlined, size: 48, color: theme.textMuted),
                        const SizedBox(height: 12),
                        Text(
                          "Let's see what you can make.",
                          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: theme.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Add a few foods you have at home to unlock recipes.',
                          style: GoogleFonts.outfit(fontSize: 13, color: theme.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _openAddFoodDialog,
                          icon: const Icon(Icons.add, size: 16),
                          label: Text(
                            'Add Food',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.navBarActivePill,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: filteredItems.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: theme.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.cardBorder, width: 1.1),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: theme.surfaceContainer,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: theme.cardBorder),
                            ),
                            child: Icon(item.icon, color: theme.textPrimary, size: 20),
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
                                    color: theme.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.nutrientHighlight,
                                  style: GoogleFonts.outfit(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                    color: theme.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          // Stepper: - [Qty Unit] +
                          Container(
                            decoration: BoxDecoration(
                              color: theme.surfaceContainer,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: theme.cardBorder),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
                                  onTap: () => _adjustQuantity(item, -1),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                    child: Icon(Icons.remove, size: 14),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Text(
                                    '${item.amount} ${item.unit}',
                                    style: GoogleFonts.outfit(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: theme.textPrimary,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(10)),
                                  onTap: () => _adjustQuantity(item, 1),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                    child: Icon(Icons.add, size: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: (40 * index).ms, duration: 250.ms);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
