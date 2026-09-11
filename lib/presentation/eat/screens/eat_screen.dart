import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:riturasa/core/di/dependency_providers.dart';
import 'package:riturasa/core/theme/riturasa_theme.dart';
import 'package:riturasa/core/widgets/pressable_scale.dart';
import 'package:riturasa/domain/models/intake_entry.dart';
import 'package:riturasa/domain/models/recipe.dart';
import 'package:riturasa/domain/models/recommendation.dart';
import 'package:riturasa/features/cycle/cycle_controller.dart';
import 'package:riturasa/features/intake/intake_controller.dart';
import 'package:riturasa/features/kitchen/kitchen_controller.dart';
import 'package:riturasa/features/nutrition/recommendation_controller.dart';
import 'package:riturasa/features/shopping/shopping_controller.dart';
import 'package:riturasa/presentation/eat/widgets/quick_food_log_sheet.dart';
import 'package:riturasa/presentation/eat/widgets/recipe_detail_sheet.dart';

/// Screen 2: Eat ("What should I eat?")
/// Core product screen that answers what meals to eat based on:
/// - Current cycle phase & ICMR-NIN nutrition focus
/// - Kitchen pantry inventory & missing ingredient status
/// - Regional & Ayurvedic dietary compatibility
class EatScreen extends ConsumerStatefulWidget {
  const EatScreen({super.key});

  @override
  ConsumerState<EatScreen> createState() => _EatScreenState();
}

class _EatScreenState extends ConsumerState<EatScreen> {
  int _selectedFilterIndex = 0;

  final List<String> _filters = [
    'All Recipes',
    'In My Kitchen (100%)',
    'Vegetarian',
    'Quick (< 20m)',
    'High Protein',
  ];

  final List<Map<String, dynamic>> _sampleRecipes = [
    {
      'id': 'rec_1',
      'name': 'Spinach Moong Dal (Palak Kootu)',
      'region': 'South Indian',
      'cuisine': 'Tamil / Coastal',
      'mealType': 'Lunch',
      'time': '25 mins',
      'servings': '2 servings',
      'availableCount': 5,
      'totalIngredients': 5,
      'calories': 340,
      'protein': '14.2 g',
      'iron': '4.8 mg',
      'fiber': '6.5 g',
      'why': 'Rich in non-heme bioavailable iron and clean plant protein. Ideal for Peak phase cellular recovery and hormone clearance.',
      'tag': 'Best Match',
      'tagColor': const Color(0xFF10B981),
      'ingredients': [
        {'name': 'Fresh Spinach (Palak)', 'qty': '150 g', 'inKitchen': true},
        {'name': 'Organic Moong Dal', 'qty': '100 g', 'inKitchen': true},
        {'name': 'A2 Desi Cow Ghee', 'qty': '1 tbsp', 'inKitchen': true},
        {'name': 'Jeera (Cumin Seeds)', 'qty': '1 tsp', 'inKitchen': true},
        {'name': 'Curry Leaves', 'qty': '1 sprig', 'inKitchen': true},
      ],
      'instructions': [
        'Cook washed moong dal in 2 cups of water with a pinch of turmeric for 3 whistles.',
        'Steam washed chopped spinach in a pan with minimal water for 3 minutes.',
        'Temper cumin seeds and curry leaves in hot A2 cow ghee until aromatic.',
        'Blend cooked dal and spinach, pour tadka over, simmer 2 mins, and serve warm.',
      ],
    },
    {
      'id': 'rec_2',
      'name': 'Sprouted Ragi & Almond Porridge',
      'region': 'Karnataka',
      'cuisine': 'Traditional Sattvic',
      'mealType': 'Breakfast',
      'time': '15 mins',
      'servings': '1 serving',
      'availableCount': 4,
      'totalIngredients': 5,
      'calories': 290,
      'protein': '9.8 g',
      'iron': '3.9 mg',
      'fiber': '8.2 g',
      'why': 'Bioavailable calcium powerhouse with slow-release complex carbohydrates for sustained vitality.',
      'tag': 'Almost Ready (Missing 1)',
      'tagColor': const Color(0xFFF59E0B),
      'ingredients': [
        {'name': 'Sprouted Ragi Flour', 'qty': '40 g', 'inKitchen': true},
        {'name': 'A2 Cow Milk / Warm Water', 'qty': '200 ml', 'inKitchen': true},
        {'name': 'Crushed Green Cardamom', 'qty': '2 pods', 'inKitchen': true},
        {'name': 'Organic Jaggery', 'qty': '1 tsp', 'inKitchen': true},
        {'name': 'Soaked Almonds', 'qty': '6 pieces', 'inKitchen': false},
      ],
      'instructions': [
        'Mix sprouted ragi flour with half cup of water to make a smooth paste without lumps.',
        'Bring remaining water or milk to a gentle boil, slowly whisking in the ragi slurry.',
        'Cook on low flame for 6-8 minutes until thick and glossy.',
        'Stir in cardamom and jaggery. Top with sliced soaked almonds.',
      ],
    },
    {
      'id': 'rec_3',
      'name': 'Methi Brown Rice Khichdi with Ghee',
      'region': 'Maharashtrian',
      'cuisine': 'Ayurvedic Rasayana',
      'mealType': 'Dinner',
      'time': '30 mins',
      'servings': '2 servings',
      'availableCount': 6,
      'totalIngredients': 6,
      'calories': 420,
      'protein': '12.5 g',
      'iron': '4.2 mg',
      'fiber': '7.1 g',
      'why': 'Tridoshic digestive Agni booster. Methi seeds regulate blood glucose while yellow dal provides gentle amino acids.',
      'tag': '100% In Kitchen',
      'tagColor': const Color(0xFF10B981),
      'ingredients': [
        {'name': 'Brown Basmati Rice', 'qty': '100 g', 'inKitchen': true},
        {'name': 'Yellow Moong Dal', 'qty': '75 g', 'inKitchen': true},
        {'name': 'Fresh Methi Leaves', 'qty': '1 cup', 'inKitchen': true},
        {'name': 'A2 Desi Cow Ghee', 'qty': '1.5 tbsp', 'inKitchen': true},
        {'name': 'Whole Black Pepper', 'qty': '4-5 corns', 'inKitchen': true},
        {'name': 'Hing (Asafoetida)', 'qty': '1 pinch', 'inKitchen': true},
      ],
      'instructions': [
        'Soak brown rice and moong dal for 20 minutes.',
        'In a cooker, warm ghee and crackle black pepper and hing.',
        'Add chopped methi leaves and sauté for 2 minutes until wilted.',
        'Add drained rice, dal, salt, and 3.5 cups of water. Pressure cook for 4 whistles.',
      ],
    },
    {
      'id': 'rec_4',
      'name': 'Black Sesame & Moringa Leaf Rasam',
      'region': 'South Indian',
      'cuisine': 'Kerala Ayurvedic',
      'mealType': 'Lunch / Soup',
      'time': '18 mins',
      'servings': '2 servings',
      'availableCount': 4,
      'totalIngredients': 6,
      'calories': 180,
      'protein': '6.4 g',
      'iron': '5.6 mg',
      'fiber': '4.5 g',
      'why': 'Supercharged with dietary zinc, magnesium, and bioavailable iron from black til and moringa.',
      'tag': 'Missing 2',
      'tagColor': const Color(0xFF6B7280),
      'ingredients': [
        {'name': 'Black Sesame Seeds', 'qty': '20 g', 'inKitchen': true},
        {'name': 'Fresh Moringa Leaves', 'qty': '1 cup', 'inKitchen': false},
        {'name': 'Ripe Tomatoes', 'qty': '2 medium', 'inKitchen': false},
        {'name': 'Tamarind Extract', 'qty': '1 tbsp', 'inKitchen': true},
        {'name': 'Crushed Garlic & Pepper', 'qty': '1 tbsp', 'inKitchen': true},
        {'name': 'Curry Leaves & Mustard', 'qty': '1 tsp', 'inKitchen': true},
      ],
      'instructions': [
        'Lightly roast black sesame seeds and coarse grind with black pepper and garlic.',
        'Boil tomatoes and moringa leaves in 3 cups of water with tamarind paste and turmeric.',
        'Stir in the freshly ground sesame spice blend and simmer for 5 minutes.',
        'Temper with mustard seeds and curry leaves in warm ghee. Sip hot.',
      ],
    },
  ];

  final List<Map<String, dynamic>> _superfoods = [
    {
      'name': 'Palak (Spinach)',
      'benefit': 'Iron & Folate',
      'badge': 'Growth Focus',
      'color': const Color(0xFF10B981),
      'icon': Icons.eco_rounded,
      'inKitchen': true,
    },
    {
      'name': 'Black Til (Sesame)',
      'benefit': 'Zinc & Healthy Lipids',
      'badge': 'Peak & Luteal',
      'color': const Color(0xFF8B5CF6),
      'icon': Icons.grain_rounded,
      'inKitchen': true,
    },
    {
      'name': 'A2 Desi Cow Ghee',
      'benefit': 'Ojas & Nutrient Absorption',
      'badge': 'Tridoshic',
      'color': const Color(0xFFF59E0B),
      'icon': Icons.water_drop_rounded,
      'inKitchen': true,
    },
    {
      'name': 'Moringa Leaves',
      'benefit': 'Iron, Calcium, Vitamin C',
      'badge': 'Period Support',
      'color': const Color(0xFFFA2C56),
      'icon': Icons.spa_rounded,
      'inKitchen': false,
    },
    {
      'name': 'Sprouted Moong',
      'benefit': 'Digestible Plant Protein',
      'badge': 'Cell Division',
      'color': const Color(0xFF00BFA5),
      'icon': Icons.grass_rounded,
      'inKitchen': true,
    },
  ];

  Map<String, dynamic> _mapRankedRecipeToUi(RankedRecipeItem ranked, BuildContext context) {
    final theme = context.rituTheme;
    final r = ranked.recipe;
    final total = r.ingredients.length;
    final avail = ranked.matchedCount;
    final isFull = avail >= total && total > 0;

    final cal = r.nutritionPerServing['energy_kcal']?.round() ?? 320;
    final pro = '${(r.nutritionPerServing['protein_g'] ?? 12.0).toStringAsFixed(1)} g';
    final iron = '${(r.nutritionPerServing['iron_mg'] ?? 3.5).toStringAsFixed(1)} mg';
    final fiber = '${(r.nutritionPerServing['fiber_g'] ?? 5.0).toStringAsFixed(1)} g';

    return {
      'id': r.id,
      'recipeItem': r,
      'rankedItem': ranked,
      'name': r.name,
      'region': r.region ?? 'Ayurvedic',
      'cuisine': r.cuisine ?? 'Indian',
      'mealType': r.mealType.isNotEmpty ? r.mealType.first : 'Main Meal',
      'time': '${(r.cookTimeMin ?? 20) + (r.prepTimeMin ?? 10)} mins',
      'servings': '${r.servings ?? 2} servings',
      'availableCount': avail,
      'totalIngredients': total,
      'calories': cal,
      'protein': pro,
      'iron': iron,
      'fiber': fiber,
      'why': r.description ?? 'Supports hormonal balance and provides key nutrients for your current cycle phase.',
      'tag': isFull ? 'In Kitchen' : '${ranked.matchPercentage.round()}% Match',
      'tagColor': isFull ? const Color(0xFF10B981) : theme.periodColor,
      'ingredients': r.ingredients.map((ing) {
        final inK = !ranked.missingIngredients.any((m) => m.foodId == ing.foodId);
        return {
          'name': ing.foodName ?? ing.foodId,
          'qty': '${ing.quantity % 1 == 0 ? ing.quantity.toInt() : ing.quantity} ${ing.unit}',
          'inKitchen': inK,
        };
      }).toList(),
      'instructions': r.instructions.isNotEmpty
          ? r.instructions
          : ['Cook fresh ingredients with mindful presence and serve warm.'],
    };
  }

  List<Map<String, dynamic>> _getFilteredRecipes(List<Map<String, dynamic>> recipes) {
    if (_selectedFilterIndex == 1) {
      // In My Kitchen (100%)
      return recipes.where((r) {
        final avail = r['availableCount'] as int? ?? 0;
        final total = r['totalIngredients'] as int? ?? 1;
        return avail >= total && total > 0;
      }).toList();
    } else if (_selectedFilterIndex == 2) {
      // Vegetarian
      return recipes; // All our curated Ayurvedic recipes are vegetarian
    } else if (_selectedFilterIndex == 3) {
      // Quick (< 20m)
      return recipes.where((r) {
        final timeStr = r['time'] as String;
        final mins = int.tryParse(timeStr.split(' ').first) ?? 30;
        return mins <= 20;
      }).toList();
    } else if (_selectedFilterIndex == 4) {
      // High Protein (> 10g)
      return recipes.where((r) {
        final proteinStr = (r['protein'] as String).replaceAll(' g', '');
        final protein = double.tryParse(proteinStr) ?? 0.0;
        return protein >= 10.0;
      }).toList();
    }
    return recipes;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.rituTheme;
    final isCompact = theme.isCompact;

    final recState = ref.watch(recommendationNotifierProvider);
    final cycleState = ref.watch(cycleNotifierProvider);
    final kitchenState = ref.watch(kitchenNotifierProvider);

    final currentPhase = cycleState.currentState?.phaseInfo;
    final phaseName = currentPhase?.phaseName ?? 'Active Phase';
    final focusNutrients = currentPhase?.priorityNutrientNames.isNotEmpty ?? false
        ? currentPhase!.priorityNutrientNames.take(2).join(' + ')
        : 'Fiber + Zinc';
    final phaseSubtitle = '$phaseName • Today\'s focus: $focusNutrients';

    final phaseColor = switch (currentPhase?.phaseId.toLowerCase()) {
      'menstrual' || 'period' => theme.periodColor,
      'follicular' || 'growth' => theme.growthColor,
      'ovulatory' || 'peak' => theme.peakColor,
      'luteal' => theme.lutealColor,
      _ => theme.peakColor,
    };

    final allRecipes = (recState.result?.rankedRecipes.isNotEmpty ?? false)
        ? recState.result!.rankedRecipes.map((r) => _mapRankedRecipeToUi(r, context)).toList()
        : _sampleRecipes;

    final filtered = _getFilteredRecipes(allRecipes);

    final kitchenFoodIds = kitchenState.items.map((i) => i.foodId).toSet();
    final superfoods = (recState.result?.rankedFoods.isNotEmpty ?? false)
        ? recState.result!.rankedFoods.map((rf) {
            return {
              'name': rf.food.name,
              'foodId': rf.food.id,
              'benefit': rf.matchReasons.isNotEmpty ? rf.matchReasons.first : 'Nutrient Dense',
              'badge': rf.matchReasons.length > 1 ? rf.matchReasons[1] : 'Phase Match',
              'color': const Color(0xFF00BFA5),
              'icon': Icons.grass_rounded,
              'inKitchen': kitchenFoodIds.contains(rf.food.id),
            };
          }).toList()
        : _superfoods;

    return Scaffold(
      backgroundColor: theme.screenBackground,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: theme.screenPadding,
            right: theme.screenPadding,
            top: 16,
            bottom: 110, // Avoid bottom floating nav bar overlap
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header with Title and + Log Food Action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'What should I eat?',
                          style: theme.screenTitleStyle,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: phaseColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                phaseSubtitle,
                                style: theme.screenSubtitleStyle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  PressableScale(
                    onTap: () => QuickFoodLogSheet.show(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.navBarActivePill,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: theme.navBarActivePill.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add_rounded, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Log Food',
                            style: GoogleFonts.outfit(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 300.ms),

              const SizedBox(height: 18),

              // 2. Filter Chips Row
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final isSelected = index == _selectedFilterIndex;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedFilterIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? theme.navBarActivePill : theme.cardBackground,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? theme.navBarActivePill : theme.cardBorder,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _filters[index],
                            style: GoogleFonts.outfit(
                              fontSize: 12.5,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? Colors.white : theme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 22),

              // 3. Section: Based on what's in your kitchen
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Based on your kitchen',
                      style: GoogleFonts.outfit(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: theme.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    '${filtered.length} meals',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Recipe Cards List
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: filtered.length,
                separatorBuilder: (context, index) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final recipe = filtered[index];
                  final int avail = recipe['availableCount'] as int;
                  final int total = recipe['totalIngredients'] as int;
                  final bool isFullMatch = avail == total;

                  return PressableScale(
                    onTap: () {
                      RecipeDetailSheet.show(
                        context,
                        recipe: recipe,
                        onAteThis: () {
                          ref.read(intakeNotifierProvider.notifier).logMeal(
                                recipeId: recipe['id'] as String?,
                                name: recipe['name'] as String? ?? 'Recipe Meal',
                                quantity: 1.0,
                                unit: 'serving',
                                mealType: MealType.fromString(recipe['mealType'] as String? ?? 'Lunch'),
                                nutrients: {
                                  'energy_kcal': (recipe['calories'] as num?)?.toDouble() ?? 320.0,
                                  'protein_g': double.tryParse((recipe['protein'] as String? ?? '14.0').replaceAll(' g', '')) ?? 14.0,
                                  'iron_mg': double.tryParse((recipe['iron'] as String? ?? '4.0').replaceAll(' mg', '')) ?? 4.0,
                                  'fiber_g': double.tryParse((recipe['fiber'] as String? ?? '6.0').replaceAll(' g', '')) ?? 6.0,
                                },
                              );
                        },
                        onAddToCart: () async {
                          final recipeItem = recipe['recipeItem'] as RecipeItem?;
                          if (recipeItem != null) {
                            final shoppingService = ref.read(shoppingServiceProvider);
                            final kitchenItems = ref.read(kitchenNotifierProvider).items;
                            final missingItems = shoppingService.generateMissingIngredients(
                              selectedRecipes: [recipeItem],
                              kitchenInventory: kitchenItems,
                            );
                            if (missingItems.isNotEmpty) {
                              await ref.read(shoppingNotifierProvider.notifier).addItems(missingItems);
                              return;
                            }
                          }

                          final ingredients = (recipe['ingredients'] as List<Map<String, dynamic>>? ?? []);
                          for (final item in ingredients.where((i) => i['inKitchen'] == false)) {
                            ref.read(shoppingNotifierProvider.notifier).addItem(
                                  foodId: 'food_${item['name']}',
                                  name: item['name'] as String,
                                  quantity: 1.0,
                                  unit: item['qty'] as String? ?? 'units',
                                  sourceRecipeIds: [recipe['id'] as String? ?? 'rec'],
                                );
                          }
                        },
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(isCompact ? 14 : 16),
                      decoration: BoxDecoration(
                        color: theme.cardBackground,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isFullMatch
                              ? const Color(0xFF10B981).withValues(alpha: 0.35)
                              : theme.cardBorder,
                          width: isFullMatch ? 1.4 : 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.cardShadow,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Meta Row: Cuisine & Availability Tag
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  '${recipe['region']} • ${recipe['mealType']}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: theme.textMuted,
                                    letterSpacing: 0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: (recipe['tagColor'] as Color).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isFullMatch) ...[
                                      const Icon(Icons.check_rounded, size: 12, color: Color(0xFF10B981)),
                                      const SizedBox(width: 3),
                                    ],
                                    Text(
                                      isFullMatch ? '✓ $avail/$total in kitchen' : '$avail/$total in kitchen',
                                      style: GoogleFonts.outfit(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        color: recipe['tagColor'] as Color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Recipe Name
                          Text(
                            recipe['name'] as String,
                            style: GoogleFonts.outfit(
                              fontSize: isCompact ? 16 : 17,
                              fontWeight: FontWeight.w800,
                              color: theme.textPrimary,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Nutrition Highlights Chips
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              _buildMacroChip(context, '${recipe['protein']} protein', theme.growthColor),
                              _buildMacroChip(context, '${recipe['iron']} iron', theme.periodColor),
                              _buildMacroChip(context, '${recipe['calories']} kcal', theme.textSecondary),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Why this matches
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.screenBackground,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.auto_awesome, size: 13, color: theme.growthColor),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    recipe['why'] as String,
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: theme.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: (70 * index).ms, duration: 250.ms);
                },
              ),

              const SizedBox(height: 26),

              // 4. Section: Foods Worth Adding Today
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Foods worth adding today',
                      style: GoogleFonts.outfit(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: theme.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Phase Superfoods',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.growthColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 122,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: superfoods.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final item = superfoods[index];
                    final Color accent = item['color'] as Color;
                    final bool inKitchen = item['inKitchen'] as bool;

                    return Container(
                      width: 156,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
                      decoration: BoxDecoration(
                        color: theme.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: accent.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(item['icon'] as IconData, size: 15, color: accent),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: inKitchen
                                      ? const Color(0xFF10B981).withValues(alpha: 0.1)
                                      : const Color(0xFFF59E0B).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  inKitchen ? 'In Pantry' : 'Needed',
                                  style: GoogleFonts.outfit(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: inKitchen ? const Color(0xFF10B981) : const Color(0xFFD97706),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            item['name'] as String,
                            style: GoogleFonts.outfit(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: theme.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item['benefit'] as String,
                            style: GoogleFonts.outfit(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                              color: theme.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroChip(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
