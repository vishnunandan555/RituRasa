import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:riturasa/core/di/dependency_providers.dart';
import 'package:riturasa/core/theme/riturasa_theme.dart';
import 'package:riturasa/core/widgets/pressable_scale.dart';
import 'package:riturasa/domain/models/food.dart';
import 'package:riturasa/domain/models/intake_entry.dart';
import 'package:riturasa/features/intake/intake_controller.dart';

/// Modal bottom sheet allowing users to quickly search and log any food item
/// or custom meal into their daily nutrition intake.
class QuickFoodLogSheet extends ConsumerStatefulWidget {
  final MealType initialMealType;

  const QuickFoodLogSheet({
    super.key,
    this.initialMealType = MealType.lunch,
  });

  static Future<void> show(
    BuildContext context, {
    MealType initialMealType = MealType.lunch,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuickFoodLogSheet(initialMealType: initialMealType),
    );
  }

  @override
  ConsumerState<QuickFoodLogSheet> createState() => _QuickFoodLogSheetState();
}

class _QuickFoodLogSheetState extends ConsumerState<QuickFoodLogSheet> {
  late MealType _selectedMealType;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customNameController = TextEditingController();
  final TextEditingController _portionController = TextEditingController(text: '100');

  List<FoodItem> _searchResults = [];
  bool _isSearching = false;
  FoodItem? _selectedFood;
  bool _isCustomMode = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedMealType = widget.initialMealType;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _customNameController.dispose();
    _portionController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    final clean = query.trim();
    if (clean.length < 2) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    try {
      final foodDaoAsync = ref.read(foodDaoProvider);
      final foodDao = foodDaoAsync.valueOrNull;
      if (foodDao != null) {
        final results = await foodDao.searchFoods(clean, limit: 10);
        if (mounted) {
          setState(() {
            _searchResults = results;
            _isSearching = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isSearching = false);
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  Future<void> _submitIntake() async {
    final portion = double.tryParse(_portionController.text.trim()) ?? 100.0;

    String foodName;
    String? foodId;
    Map<String, double> nutrients = {};

    if (_selectedFood != null) {
      final f = _selectedFood!;
      foodId = f.id;
      foodName = f.name;
      final scale = portion / 100.0;
      nutrients = {
        'energy_kcal': (f.energyKcal ?? 120.0) * scale,
        'protein_g': (f.proteinG ?? 3.5) * scale,
        'carbohydrate_g': (f.carbohydrateG ?? 20.0) * scale,
        'fat_g': (f.fatG ?? 2.0) * scale,
        'fiber_g': (f.fiberG ?? 2.5) * scale,
        'iron_mg': (f.ironMg ?? 1.5) * scale,
        'calcium_mg': (f.calciumMg ?? 40.0) * scale,
      };
    } else {
      foodName = _customNameController.text.trim();
      if (foodName.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter or select a food name.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      nutrients = {
        'energy_kcal': portion * 1.5,
        'protein_g': portion * 0.05,
      };
    }

    setState(() => _isSubmitting = true);
    HapticFeedback.mediumImpact();

    await ref.read(intakeNotifierProvider.notifier).logMeal(
          foodId: foodId,
          name: foodName,
          quantity: portion,
          unit: 'g',
          mealType: _selectedMealType,
          nutrients: nutrients,
        );

    if (mounted) {
      setState(() => _isSubmitting = false);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logged "$foodName" to ${_selectedMealType.name.toUpperCase()}!'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.rituTheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: theme.screenBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: theme.screenPadding,
            vertical: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle Pill
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: theme.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title and Mode Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Log Food & Meals',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: theme.textPrimary,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _isCustomMode = !_isCustomMode;
                        _selectedFood = null;
                      });
                    },
                    icon: Icon(
                      _isCustomMode ? Icons.search_rounded : Icons.edit_note_rounded,
                      size: 16,
                      color: theme.navBarActivePill,
                    ),
                    label: Text(
                      _isCustomMode ? 'Search ICMR' : 'Custom Entry',
                      style: GoogleFonts.outfit(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: theme.navBarActivePill,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Meal Type Selector Chips
              Text(
                'Meal Type',
                style: GoogleFonts.outfit(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: theme.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildMealTypeChip(MealType.breakfast, 'Breakfast', Icons.wb_sunny_outlined, theme),
                    const SizedBox(width: 8),
                    _buildMealTypeChip(MealType.lunch, 'Lunch', Icons.lunch_dining_outlined, theme),
                    const SizedBox(width: 8),
                    _buildMealTypeChip(MealType.snack, 'Snack', Icons.cookie_outlined, theme),
                    const SizedBox(width: 8),
                    _buildMealTypeChip(MealType.dinner, 'Dinner', Icons.nightlight_round_outlined, theme),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (!_isCustomMode) ...[
                // ICMR Search Field
                TextField(
                  controller: _searchController,
                  onChanged: _performSearch,
                  style: GoogleFonts.outfit(fontSize: 14, color: theme.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search 2,500+ ICMR foods (e.g. Ragi, Palak, Moong)',
                    hintStyle: GoogleFonts.outfit(fontSize: 13, color: theme.textSecondary.withValues(alpha: 0.7)),
                    prefixIcon: Icon(Icons.search_rounded, color: theme.textSecondary, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _performSearch('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: theme.cardBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: theme.cardBorder),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),

                if (_isSearching)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))),
                  ),

                // Search Results
                if (_searchResults.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    constraints: const BoxConstraints(maxHeight: 180),
                    decoration: BoxDecoration(
                      color: theme.cardBackground,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: theme.cardBorder),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _searchResults.length,
                      separatorBuilder: (_, __) => Divider(height: 1, color: theme.cardBorder),
                      itemBuilder: (context, idx) {
                        final food = _searchResults[idx];
                        final isSelected = _selectedFood?.id == food.id;
                        return ListTile(
                          dense: true,
                          title: Text(
                            food.name,
                            style: GoogleFonts.outfit(
                              fontSize: 13.5,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? theme.navBarActivePill : theme.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            '${food.category} • ${(food.energyKcal ?? 0).toInt()} kcal / 100g',
                            style: GoogleFonts.outfit(fontSize: 11.5, color: theme.textSecondary),
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check_circle_rounded, color: theme.navBarActivePill, size: 18)
                              : null,
                          onTap: () {
                            setState(() {
                              _selectedFood = food;
                              _searchResults = [];
                              _searchController.text = food.name;
                            });
                          },
                        );
                      },
                    ),
                  ),
              ] else ...[
                // Custom Meal Name
                TextField(
                  controller: _customNameController,
                  style: GoogleFonts.outfit(fontSize: 14, color: theme.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Meal or Food Name',
                    hintText: 'e.g. Homemade Dal & Brown Rice',
                    filled: true,
                    fillColor: theme.cardBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: theme.cardBorder),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Portion Input
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _portionController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: GoogleFonts.outfit(fontSize: 14, color: theme.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Portion / Quantity (grams)',
                        hintText: '100',
                        filled: true,
                        fillColor: theme.cardBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: theme.cardBorder),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Quick portion buttons
                  _buildPortionPreset('100g', '100', theme),
                  const SizedBox(width: 6),
                  _buildPortionPreset('150g', '150', theme),
                  const SizedBox(width: 6),
                  _buildPortionPreset('200g', '200', theme),
                ],
              ),

              const SizedBox(height: 20),

              // Submit Button
              PressableScale(
                onTap: _isSubmitting ? null : _submitIntake,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: theme.navBarActivePill,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: theme.navBarActivePill.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        _isSubmitting ? 'Logging...' : 'Log to Today\'s Intake',
                        style: GoogleFonts.outfit(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealTypeChip(MealType type, String label, IconData icon, RituRasaThemeExtension theme) {
    final isSelected = _selectedMealType == type;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => setState(() => _selectedMealType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.navBarActivePill : theme.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? theme.navBarActivePill : theme.cardBorder,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : theme.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : theme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortionPreset(String label, String value, RituRasaThemeExtension theme) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        setState(() {
          _portionController.text = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: theme.cardBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.cardBorder),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: theme.textSecondary,
          ),
        ),
      ),
    );
  }
}
