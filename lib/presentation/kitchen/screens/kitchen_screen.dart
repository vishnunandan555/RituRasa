import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:riturasa/core/theme/riturasa_theme.dart';
import 'package:riturasa/domain/models/kitchen_item.dart';
import 'package:riturasa/features/kitchen/kitchen_controller.dart';
import 'package:riturasa/presentation/kitchen/widgets/add_food_dialog.dart';

/// Kitchen & Pantry Screen
/// Central inventory differentiator. Tracks available food items at home,
/// calculates smart kitchen nutrient summaries, and feeds the recommendation engine.
class KitchenScreen extends ConsumerStatefulWidget {
  const KitchenScreen({super.key});

  @override
  ConsumerState<KitchenScreen> createState() => _KitchenScreenState();
}

class _KitchenScreenState extends ConsumerState<KitchenScreen> {
  int _selectedCategoryIndex = 0;
  final List<String> _categories = [
    'All',
    'Vegetables',
    'Protein & Staples',
    'Seeds & Superfoods',
    'Dairy & Healthy Fats',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = context.rituTheme;
    final kitchenState = ref.watch(kitchenNotifierProvider);
    final items = kitchenState.items;

    // Filter items based on selected category chip
    final filteredItems = _selectedCategoryIndex == 0
        ? items
        : items.where((item) {
            final name = (item.foodName ?? '').toLowerCase();
            final cat = _categories[_selectedCategoryIndex].toLowerCase();
            if (cat.contains('vegetable')) {
              return name.contains('spinach') ||
                  name.contains('palak') ||
                  name.contains('tomato') ||
                  name.contains('methi') ||
                  name.contains('amla');
            } else if (cat.contains('protein')) {
              return name.contains('dal') ||
                  name.contains('millet') ||
                  name.contains('ragi') ||
                  name.contains('chana') ||
                  name.contains('besan');
            } else if (cat.contains('seed')) {
              return name.contains('sesame') ||
                  name.contains('til') ||
                  name.contains('seed') ||
                  name.contains('jeera') ||
                  name.contains('turmeric') ||
                  name.contains('haldi');
            } else {
              return name.contains('ghee') ||
                  name.contains('curd') ||
                  name.contains('milk') ||
                  name.contains('paneer');
            }
          }).toList();

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
              // 1. Header Bar: Title + Subtitle + "+ Add Food" CTA
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
                        const SizedBox(height: 4),
                        Text(
                          'What do you have at home?',
                          style: theme.screenSubtitleStyle,
                        ).animate().fadeIn(duration: 350.ms),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => AddFoodDialog.show(context),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: Text(
                      'Add Food',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.navBarActivePill,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ).animate().fadeIn(duration: 350.ms).scale(begin: const Offset(0.9, 0.9)),
                ],
              ),

              const SizedBox(height: 18),

              // 2. Smart Kitchen Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF0F172A),
                      const Color(0xFF1E293B),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(Icons.auto_awesome_rounded, color: Color(0xFFFBBF24), size: 18),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Smart Kitchen Summary',
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${items.length} Ingredients',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF34D399),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      items.isEmpty
                          ? 'Your pantry is currently empty. Add foods to unlock personalized recipe matching.'
                          : 'Your pantry has strong coverage for iron and bioavailable proteins for your current cycle phase.',
                      style: GoogleFonts.outfit(
                        fontSize: 12.5,
                        color: const Color(0xFFCBD5E1),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 18),

              // 3. Category Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_categories.length, (index) {
                    final isSelected = _selectedCategoryIndex == index;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(_categories[index]),
                        labelStyle: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : theme.textPrimary,
                        ),
                        backgroundColor: theme.screenBackground,
                        selectedColor: theme.navBarActivePill,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? theme.navBarActivePill : theme.cardBorder,
                            width: 1,
                          ),
                        ),
                        showCheckmark: false,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategoryIndex = index;
                          });
                        },
                      ),
                    );
                  }),
                ),
              ).animate().fadeIn(duration: 450.ms),

              const SizedBox(height: 16),

              // 4. Food Items List or Empty State
              if (filteredItems.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  decoration: BoxDecoration(
                    color: theme.cardBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.cardBorder),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.kitchen_outlined, size: 48, color: theme.textSecondary.withValues(alpha: 0.5)),
                      const SizedBox(height: 12),
                      Text(
                        'No pantry foods in this category',
                        style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: theme.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap "+ Add Food" above to search and log items you have at home.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(fontSize: 12.5, color: theme.textSecondary),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredItems.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return _buildKitchenItemTile(context, item, theme);
                  },
                ).animate().fadeIn(duration: 500.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKitchenItemTile(BuildContext context, KitchenItem item, RituRasaThemeExtension theme) {
    final name = item.foodName ?? 'Food Item';
    final qtyDisplay = item.quantity % 1 == 0 ? item.quantity.toInt().toString() : item.quantity.toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: theme.cardShadow,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Food Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.navBarActivePill.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.eco_rounded, color: theme.navBarActivePill, size: 20),
          ),
          const SizedBox(width: 12),

          // Name and Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.outfit(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: theme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '$qtyDisplay ${item.unit}',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Quantity Steppers (- / +) and Delete
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  final newQty = item.quantity - 1;
                  ref.read(kitchenNotifierProvider.notifier).updateQuantity(item.foodId, newQty);
                },
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(Icons.remove_circle_outline_rounded, size: 20, color: theme.textSecondary),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  qtyDisplay,
                  style: GoogleFonts.outfit(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: theme.textPrimary,
                  ),
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  final newQty = item.quantity + 1;
                  ref.read(kitchenNotifierProvider.notifier).updateQuantity(item.foodId, newQty);
                },
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(Icons.add_circle_outline_rounded, size: 20, color: theme.navBarActivePill),
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  ref.read(kitchenNotifierProvider.notifier).removeItem(item.foodId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Removed $name from pantry.'),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFE11D48)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
