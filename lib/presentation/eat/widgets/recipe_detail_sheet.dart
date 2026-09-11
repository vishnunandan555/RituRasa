import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:riturasa/core/theme/riturasa_theme.dart';
import 'package:riturasa/core/widgets/pressable_scale.dart';

/// Modal bottom sheet displaying complete recipe information,
/// ingredient availability against the kitchen, nutrition breakdown,
/// and primary actions ("I Ate This" and "Add Missing Ingredients to Cart").
class RecipeDetailSheet extends StatefulWidget {
  final Map<String, dynamic> recipe;
  final VoidCallback? onAteThis;
  final VoidCallback? onAddToCart;

  const RecipeDetailSheet({
    super.key,
    required this.recipe,
    this.onAteThis,
    this.onAddToCart,
  });

  static Future<void> show(
    BuildContext context, {
    required Map<String, dynamic> recipe,
    VoidCallback? onAteThis,
    VoidCallback? onAddToCart,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RecipeDetailSheet(
        recipe: recipe,
        onAteThis: onAteThis,
        onAddToCart: onAddToCart,
      ),
    );
  }

  @override
  State<RecipeDetailSheet> createState() => _RecipeDetailSheetState();
}

class _RecipeDetailSheetState extends State<RecipeDetailSheet> {
  bool _hasLoggedMeal = false;
  bool _hasAddedToCart = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.rituTheme;
    final isCompact = theme.isCompact;
    final r = widget.recipe;

    final String name = r['name'] as String? ?? 'Spinach Moong Dal';
    final String region = r['region'] as String? ?? 'South Indian';
    final String mealType = r['mealType'] as String? ?? 'Lunch';
    final String time = r['time'] as String? ?? '25 mins';
    final String servings = r['servings'] as String? ?? '2 servings';
    final String why = r['why'] as String? ??
        'Rich in non-heme bioavailable iron and plant protein. Paired with mild cumin and turmeric to support digestion and hormone balance.';

    final List<Map<String, dynamic>> ingredients =
        (r['ingredients'] as List<Map<String, dynamic>>?) ?? [
      {'name': 'Spinach (Palak)', 'qty': '150 g', 'inKitchen': true},
      {'name': 'Yellow Moong Dal', 'qty': '100 g', 'inKitchen': true},
      {'name': 'Desi Cow Ghee', 'qty': '1 tbsp', 'inKitchen': true},
      {'name': 'Jeera (Cumin Seeds)', 'qty': '1 tsp', 'inKitchen': true},
      {'name': 'Fresh Grated Coconut', 'qty': '50 g', 'inKitchen': false},
      {'name': 'Curry Leaves', 'qty': '1 sprig', 'inKitchen': true},
    ];

    final List<String> instructions = (r['instructions'] as List<String>?) ?? [
      'Wash yellow moong dal thoroughly and pressure cook with 2 cups of water and a pinch of turmeric for 3 whistles.',
      'Finely chop fresh washed spinach leaves and steam lightly in a pan with minimal water for 3-4 minutes.',
      'In a tadka pan, heat 1 tbsp A2 desi cow ghee. Add cumin seeds and curry leaves until fragrant.',
      'Combine cooked dal, steamed spinach, and grated coconut. Stir in the aromatic ghee tadka and simmer for 2 minutes. Serve warm.',
    ];

    final missingCount = ingredients.where((i) => i['inKitchen'] == false).length;

    return Container(
      decoration: BoxDecoration(
        color: theme.screenBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.88,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: EdgeInsets.symmetric(
              horizontal: theme.screenPadding,
              vertical: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    width: 42,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: theme.textMuted.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Recipe Header Pill
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.growthColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$region • $mealType',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: theme.growthColor,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.schedule_rounded, size: 14, color: theme.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          time,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: theme.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(Icons.people_outline_rounded, size: 14, color: theme.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          servings,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: theme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Recipe Title
                Text(
                  name,
                  style: theme.screenTitleStyle.copyWith(
                    fontSize: isCompact ? 20 : 22,
                  ),
                ),
                const SizedBox(height: 16),

                // Core Nutrition per Serving Card
                Container(
                  padding: EdgeInsets.all(isCompact ? 12 : 16),
                  decoration: BoxDecoration(
                    color: theme.cardBackground,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: theme.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nutrition per Serving',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: theme.textSecondary,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildNutrientStat(context, 'Calories', '340 kcal', theme.energyCategoryColor),
                          _buildNutrientStat(context, 'Protein', '14.2 g', theme.growthColor),
                          _buildNutrientStat(context, 'Iron', '4.8 mg', theme.periodColor),
                          _buildNutrientStat(context, 'Fiber', '6.5 g', theme.peakColor),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildNutrientStat(context, 'Carbs', '48 g', theme.textSecondary),
                          _buildNutrientStat(context, 'Calcium', '180 mg', theme.mineralsCategoryColor),
                          _buildNutrientStat(context, 'Magnesium', '95 mg', theme.vitaminsCategoryColor),
                          _buildNutrientStat(context, 'Zinc', '2.2 mg', theme.growthColor),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Why Recommended / Ayurvedic Fit
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.energySubCardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.energyCategoryColor.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.auto_awesome_rounded, color: theme.energyCategoryColor, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Why this matches your cycle context',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: theme.energyCategoryColor,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              why,
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: theme.textPrimary,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Ingredients with Kitchen Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ingredients & Availability',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: theme.textPrimary,
                      ),
                    ),
                    Text(
                      missingCount == 0
                          ? '✓ All in Kitchen'
                          : '$missingCount Missing',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: missingCount == 0
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: ingredients.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final item = ingredients[index];
                    final bool inKitchen = item['inKitchen'] as bool? ?? true;

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: theme.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.cardBorder),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            inKitchen ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                            size: 18,
                            color: inKitchen ? const Color(0xFF10B981) : theme.textMuted,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item['name'] as String,
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: theme.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            item['qty'] as String,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: inKitchen
                                  ? const Color(0xFF10B981).withValues(alpha: 0.1)
                                  : const Color(0xFFF59E0B).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              inKitchen ? 'In Pantry' : 'Need',
                              style: GoogleFonts.outfit(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: inKitchen
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFD97706),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Preparation Instructions
                Text(
                  'Preparation Instructions',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: theme.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),

                for (int i = 0; i < instructions.length; i++) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: theme.navBarActivePill,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${i + 1}',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            instructions[i],
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: theme.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    // Primary: I Ate This
                    Expanded(
                      flex: 6,
                      child: PressableScale(
                        onTap: _hasLoggedMeal
                            ? null
                            : () {
                                HapticFeedback.mediumImpact();
                                setState(() => _hasLoggedMeal = true);
                                widget.onAteThis?.call();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Logged "$name" to your daily nutrition!',
                                      style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                                    ),
                                    backgroundColor: const Color(0xFF10B981),
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: _hasLoggedMeal
                                ? const Color(0xFF10B981)
                                : theme.navBarActivePill,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: (_hasLoggedMeal
                                        ? const Color(0xFF10B981)
                                        : theme.navBarActivePill)
                                    .withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _hasLoggedMeal ? Icons.check_circle_rounded : Icons.restaurant_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _hasLoggedMeal ? 'Logged!' : 'I Ate This',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    if (missingCount > 0) ...[
                      const SizedBox(width: 10),
                      // Secondary: Add Missing to Cart
                      Expanded(
                        flex: 5,
                        child: PressableScale(
                          onTap: _hasAddedToCart
                              ? null
                              : () {
                                  HapticFeedback.lightImpact();
                                  setState(() => _hasAddedToCart = true);
                                  widget.onAddToCart?.call();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Added $missingCount missing ingredients to Cart!',
                                        style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                                      ),
                                      backgroundColor: theme.navBarActivePill,
                                      behavior: SnackBarBehavior.floating,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: theme.cardBackground,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _hasAddedToCart
                                    ? const Color(0xFF10B981)
                                    : theme.cardBorder,
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _hasAddedToCart
                                      ? Icons.check_rounded
                                      : Icons.add_shopping_cart_rounded,
                                  color: _hasAddedToCart
                                      ? const Color(0xFF10B981)
                                      : theme.textPrimary,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _hasAddedToCart ? 'In Cart' : 'Missing to Cart',
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: _hasAddedToCart
                                        ? const Color(0xFF10B981)
                                        : theme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNutrientStat(BuildContext context, String label, String value, Color color) {
    final theme = context.rituTheme;
    final isCompact = theme.isCompact;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: isCompact ? 10 : 11,
                fontWeight: FontWeight.w600,
                color: theme.textMuted,
              ),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: isCompact ? 12 : 13,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
