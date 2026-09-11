import 'package:flutter/material.dart';
import 'package:riturasa/core/theme/riturasa_theme.dart';
import 'package:riturasa/domain/models/nutrient_category.dart';
import 'category_circular_dial.dart';
import 'category_sub_card.dart';

/// Nutrition Overview Section for Home Screen.
/// Arranges the 4 categories (Energy, Macro, Vitamins, Minerals) with:
/// - LEFT: Large circular dial displaying the LEAST FILLED category (biggest deficit).
/// - RIGHT: 3 stacked horizontal pill sub-cards.
/// - Interactive: Tapping any right sub-card switches it to the main circular ring!
class NutritionOverviewSection extends StatefulWidget {
  final List<NutrientCategoryProgress> categories;

  const NutritionOverviewSection({
    super.key,
    required this.categories,
  });

  @override
  State<NutritionOverviewSection> createState() => _NutritionOverviewSectionState();
}

class _NutritionOverviewSectionState extends State<NutritionOverviewSection> {
  NutrientCategoryType? _overrideFocusedType;

  @override
  Widget build(BuildContext context) {
    final theme = context.rituTheme;

    if (widget.categories.isEmpty) {
      return const SizedBox.shrink();
    }

    // Default focused category is the least filled category (first in sorted list)
    final focusedCategory = _overrideFocusedType != null
        ? widget.categories.firstWhere(
            (c) => c.type == _overrideFocusedType,
            orElse: () => widget.categories.first,
          )
        : widget.categories.first;

    // The other 3 categories displayed on the right
    final subCategories = widget.categories.where((c) => c.type != focusedCategory.type).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Text(
          'Daily Nutrition Focus',
          style: theme.sectionHeaderStyle,
        ),
        const SizedBox(height: 12),

        // Main Composite Layout: Circular Ring Left + 3 Sub-Cards Right
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left: Large Circular Progress Dial (Least Filled / Focused)
            Expanded(
              flex: 48,
              child: CategoryCircularDial(
                category: focusedCategory,
                onTap: () {
                  // If user tapped focused, reset override to return to auto least-filled
                  if (_overrideFocusedType != null) {
                    setState(() {
                      _overrideFocusedType = null;
                    });
                  }
                },
              ),
            ),

            const SizedBox(width: 12),

            // Right: 3 Stacked Sub-Cards
            Expanded(
              flex: 52,
              child: Column(
                children: [
                  for (int i = 0; i < subCategories.length; i++) ...[
                    if (i > 0) const SizedBox(height: 7),
                    CategorySubCard(
                      category: subCategories[i],
                      onTap: () {
                        setState(() {
                          _overrideFocusedType = subCategories[i].type;
                        });
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
