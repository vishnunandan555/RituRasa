import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:riturasa/core/di/dependency_providers.dart';
import 'package:riturasa/core/theme/riturasa_theme.dart';
import 'package:riturasa/features/kitchen/kitchen_controller.dart';

class AddFoodDialog extends ConsumerStatefulWidget {
  const AddFoodDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const AddFoodDialog(),
    );
  }

  @override
  ConsumerState<AddFoodDialog> createState() => _AddFoodDialogState();
}

class _AddFoodDialogState extends ConsumerState<AddFoodDialog> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController(text: '1');
  String _selectedUnit = 'units';

  Map<String, dynamic>? _selectedFood;
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  static const List<String> _units = [
    'units',
    'g',
    'kg',
    'ml',
    'l',
    'bunches',
    'cups',
    'tbsp',
    'tsp',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  Future<void> _onSearchChanged(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);

    try {
      final foodDao = await ref.read(foodDaoProvider.future);
      final res = await foodDao.searchFoods(trimmed, limit: 20);
      if (mounted) {
        setState(() {
          _searchResults = res.valueOrNull ?? [];
          _isSearching = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _addFood() async {
    if (_selectedFood == null) return;

    final foodId = _selectedFood!['id']?.toString() ?? 'F_${DateTime.now().millisecondsSinceEpoch}';
    final foodName = _selectedFood!['name']?.toString() ?? 'Food Item';
    final qty = double.tryParse(_qtyController.text.trim()) ?? 1.0;

    await ref.read(kitchenNotifierProvider.notifier).addItem(
          foodId: foodId,
          foodName: foodName,
          quantity: qty,
          unit: _selectedUnit,
        );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Added $foodName to your kitchen pantry.',
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.rituTheme;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 580),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title & Close
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: theme.navBarActivePill.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.kitchen_rounded, size: 18, color: theme.navBarActivePill),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Add Pantry Food',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: theme.textPrimary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Search Bar
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: GoogleFonts.outfit(fontSize: 14, color: theme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search 2,525+ Indian foods & staples...',
                hintStyle: GoogleFonts.outfit(fontSize: 13, color: theme.textSecondary),
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
                filled: true,
                fillColor: theme.screenBackground,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.cardBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.cardBorder),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Food selection display or search results list
            if (_selectedFood != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedFood!['name']?.toString() ?? '',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: theme.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _selectedFood!['category']?.toString() ?? 'Staple',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: theme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: () => setState(() => _selectedFood = null),
                    ),
                  ],
                ),
              )
            else
              Expanded(
                child: _searchResults.isEmpty
                    ? Center(
                        child: Text(
                          _searchController.text.trim().length < 2
                              ? 'Type at least 2 characters to search foods from the ICMR-NIN database.'
                              : 'No matching foods found.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(fontSize: 12.5, color: theme.textSecondary),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: _searchResults.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final food = _searchResults[index];
                          final name = food['name']?.toString() ?? '';
                          final cat = food['category']?.toString() ?? '';

                          return ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            title: Text(
                              name,
                              style: GoogleFonts.outfit(fontSize: 13.5, fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              cat,
                              style: GoogleFonts.outfit(fontSize: 11, color: theme.textSecondary),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                            onTap: () {
                              setState(() {
                                _selectedFood = food;
                                _searchResults = [];
                              });
                            },
                          );
                        },
                      ),
              ),

            const SizedBox(height: 14),

            // Quantity & Unit Inputs
            if (_selectedFood != null) ...[
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quantity',
                          style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _qtyController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Unit',
                          style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: theme.cardBorder),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _selectedUnit,
                              items: _units.map((u) {
                                return DropdownMenuItem(value: u, child: Text(u, style: GoogleFonts.outfit(fontSize: 13)));
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedUnit = val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
            ],

            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.navBarActivePill,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _selectedFood != null ? _addFood : null,
                child: Text(
                  'Add to Kitchen',
                  style: GoogleFonts.outfit(fontSize: 14.5, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
