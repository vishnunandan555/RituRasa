import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:riturasa/core/theme/riturasa_theme.dart';

class FoodSearchCandidate {
  final String canonicalName;
  final String hindiName;
  final String category;
  final String nutrientTag;
  final String defaultUnit;

  const FoodSearchCandidate({
    required this.canonicalName,
    required this.hindiName,
    required this.category,
    required this.nutrientTag,
    required this.defaultUnit,
  });
}

class AddFoodDialog extends StatefulWidget {
  final Function(String name, String qty, String category, String nutrientTag) onAdd;

  const AddFoodDialog({super.key, required this.onAdd});

  @override
  State<AddFoodDialog> createState() => _AddFoodDialogState();
}

class _AddFoodDialogState extends State<AddFoodDialog> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController(text: '1');
  FoodSearchCandidate? _selectedCandidate;

  static const List<FoodSearchCandidate> _referenceFoods = [
    FoodSearchCandidate(
      canonicalName: 'Spinach',
      hindiName: 'Palak (पालक)',
      category: 'Vegetables',
      nutrientTag: 'Iron · Folate · Vitamin C',
      defaultUnit: 'bunch',
    ),
    FoodSearchCandidate(
      canonicalName: 'Yellow Moong Dal',
      hindiName: 'Mung (मूंग दाल)',
      category: 'Protein & Staples',
      nutrientTag: 'Bioavailable Protein · Fiber',
      defaultUnit: '500 g',
    ),
    FoodSearchCandidate(
      canonicalName: 'Finger Millet',
      hindiName: 'Ragi (रागी / Mandua)',
      category: 'Protein & Staples',
      nutrientTag: 'Calcium · Iron',
      defaultUnit: '1 kg',
    ),
    FoodSearchCandidate(
      canonicalName: 'Sesame Seeds',
      hindiName: 'Til (तिल)',
      category: 'Seeds & Superfoods',
      nutrientTag: 'Zinc · Healthy Lipids · Calcium',
      defaultUnit: '200 g',
    ),
    FoodSearchCandidate(
      canonicalName: 'Fenugreek Leaves / Seeds',
      hindiName: 'Methi (मेथी)',
      category: 'Vegetables',
      nutrientTag: 'Iron · Antispasmodic',
      defaultUnit: '2 bunches',
    ),
    FoodSearchCandidate(
      canonicalName: 'A2 Desi Cow Ghee',
      hindiName: 'Ghritam (घी)',
      category: 'Dairy & Healthy Fats',
      nutrientTag: 'Ojas Builder · Fat Soluble Vit',
      defaultUnit: '500 ml',
    ),
    FoodSearchCandidate(
      canonicalName: 'Indian Gooseberry',
      hindiName: 'Amla (आंवला)',
      category: 'Vegetables',
      nutrientTag: 'High Vitamin C · Antioxidant',
      defaultUnit: '250 g',
    ),
    FoodSearchCandidate(
      canonicalName: 'Chickpeas',
      hindiName: 'Kabuli Chana (चना)',
      category: 'Protein & Staples',
      nutrientTag: 'Plant Protein · Folate',
      defaultUnit: '500 g',
    ),
    FoodSearchCandidate(
      canonicalName: 'Fresh Curd / Yogurt',
      hindiName: 'Dahi (दही)',
      category: 'Dairy & Healthy Fats',
      nutrientTag: 'Probiotics · B12',
      defaultUnit: '400 g',
    ),
    FoodSearchCandidate(
      canonicalName: 'Tomato',
      hindiName: 'Tamatar (टमाटर)',
      category: 'Vegetables',
      nutrientTag: 'Lycopene · Vitamin C',
      defaultUnit: '500 g',
    ),
  ];

  List<FoodSearchCandidate> _filteredFoods = _referenceFoods;

  void _filter(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _filteredFoods = _referenceFoods;
      } else {
        final q = query.toLowerCase();
        _filteredFoods = _referenceFoods.where((f) {
          return f.canonicalName.toLowerCase().contains(q) ||
              f.hindiName.toLowerCase().contains(q) ||
              f.category.toLowerCase().contains(q);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.rituTheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: theme.cardBorder),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add Food to Kitchen',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: theme.textPrimary,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: theme.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              onChanged: _filter,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search food (e.g. Palak, Moong, Ragi, Ghee)...',
                hintStyle: GoogleFonts.outfit(color: theme.textMuted, fontSize: 13),
                prefixIcon: Icon(Icons.search_rounded, color: theme.textSecondary, size: 20),
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
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _filteredFoods.length,
                separatorBuilder: (_, _) => const SizedBox(height: 6),
                itemBuilder: (context, idx) {
                  final food = _filteredFoods[idx];
                  final isSelected = _selectedCandidate == food;
                  return ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    tileColor: isSelected ? theme.navBarActivePill.withValues(alpha: 0.08) : Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected ? theme.navBarActivePill : Colors.transparent,
                      ),
                    ),
                    title: Text(
                      '${food.canonicalName} · ${food.hindiName}',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: theme.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      '${food.category}  •  ${food.nutrientTag}',
                      style: GoogleFonts.outfit(fontSize: 11, color: theme.textSecondary),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: theme.navBarActivePill, size: 20)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedCandidate = food;
                        _qtyController.text = food.defaultUnit;
                      });
                    },
                  );
                },
              ),
            ),
            if (_selectedCandidate != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _qtyController,
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        labelStyle: GoogleFonts.outfit(color: theme.textSecondary, fontSize: 13),
                        filled: true,
                        fillColor: theme.surfaceContainer,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.cardBorder),
                        ),
                      ),
                      style: GoogleFonts.outfit(fontSize: 14, color: theme.textPrimary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.navBarActivePill,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      widget.onAdd(
                        '${_selectedCandidate!.canonicalName} (${_selectedCandidate!.hindiName.split(' ').first})',
                        _qtyController.text,
                        _selectedCandidate!.category,
                        _selectedCandidate!.nutrientTag,
                      );
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Add',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
