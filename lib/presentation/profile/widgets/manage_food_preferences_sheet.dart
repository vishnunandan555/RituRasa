import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:riturasa/core/theme/riturasa_theme.dart';
import 'package:riturasa/domain/models/user_profile.dart';
import 'package:riturasa/features/profile/profile_controller.dart';

/// Modal bottom sheet allowing the user to manage favorite foods and dietary exclusions/allergies.
class ManageFoodPreferencesSheet extends ConsumerStatefulWidget {
  final UserPreferences preferences;

  const ManageFoodPreferencesSheet({super.key, required this.preferences});

  static Future<void> show(BuildContext context, UserPreferences preferences) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ManageFoodPreferencesSheet(preferences: preferences),
    );
  }

  @override
  ConsumerState<ManageFoodPreferencesSheet> createState() => _ManageFoodPreferencesSheetState();
}

class _ManageFoodPreferencesSheetState extends ConsumerState<ManageFoodPreferencesSheet> {
  late List<String> _allergies;
  final TextEditingController _textController = TextEditingController();

  static const _quickStaples = [
    'Peanuts',
    'Tree Nuts',
    'Dairy / Lactose',
    'Gluten',
    'Soy',
    'Refined Sugar',
    'Excess Red Chili',
    'Deep Fried Foods',
  ];

  @override
  void initState() {
    super.initState();
    _allergies = List.from(widget.preferences.allergies);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _addItem(String item) {
    final trimmed = item.trim();
    if (trimmed.isNotEmpty && !_allergies.contains(trimmed)) {
      setState(() => _allergies.add(trimmed));
      _textController.clear();
    }
  }

  void _removeItem(String item) {
    setState(() => _allergies.remove(item));
  }

  Future<void> _save() async {
    final updated = widget.preferences.copyWith(
      allergies: _allergies,
      updatedAt: DateTime.now(),
    );

    await ref.read(profileNotifierProvider.notifier).updatePreferences(updated);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Dietary exclusions & allergies updated.',
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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 24 + bottomInset,
      ),
      decoration: BoxDecoration(
        color: theme.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Manage Exclusions & Allergies',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: theme.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Active Exclusions Chips
            Text(
              'Active Exclusions (${_allergies.length})',
              style: GoogleFonts.outfit(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: theme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            if (_allergies.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'No active allergies or food exclusions logged.',
                  style: GoogleFonts.outfit(fontSize: 13, color: theme.textSecondary),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _allergies.map((item) {
                  return Chip(
                    label: Text(item),
                    labelStyle: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFE11D48),
                    ),
                    backgroundColor: const Color(0xFFFFF1F2),
                    deleteIcon: const Icon(Icons.cancel_rounded, size: 16, color: Color(0xFFE11D48)),
                    onDeleted: () => _removeItem(item),
                    side: const BorderSide(color: Color(0xFFFFCCD5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  );
                }).toList(),
              ),
            const SizedBox(height: 16),

            // Add Custom Exclusion Input
            Text(
              'Add Custom Exclusion / Allergy',
              style: GoogleFonts.outfit(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: theme.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    style: GoogleFonts.outfit(fontSize: 14, color: theme.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'e.g. Mustard, Shellfish, Bell pepper...',
                      hintStyle: GoogleFonts.outfit(fontSize: 13, color: theme.textSecondary),
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
                    onSubmitted: _addItem,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.navBarActivePill,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _addItem(_textController.text),
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Quick Add Chips
            Text(
              'Quick Add Common Exclusions',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickStaples.map((staple) {
                final isAdded = _allergies.contains(staple);
                return ActionChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isAdded ? Icons.check_rounded : Icons.add_rounded,
                        size: 14,
                        color: isAdded ? const Color(0xFF10B981) : theme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(staple),
                    ],
                  ),
                  labelStyle: GoogleFonts.outfit(
                    fontSize: 11.5,
                    color: isAdded ? const Color(0xFF10B981) : theme.textPrimary,
                    fontWeight: isAdded ? FontWeight.w700 : FontWeight.w500,
                  ),
                  backgroundColor: theme.screenBackground,
                  side: BorderSide(color: isAdded ? const Color(0xFF10B981) : theme.cardBorder),
                  onPressed: () {
                    if (isAdded) {
                      _removeItem(staple);
                    } else {
                      _addItem(staple);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.navBarActivePill,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _save,
                child: Text(
                  'Save Exclusions',
                  style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
