import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:riturasa/core/theme/riturasa_theme.dart';
import 'package:riturasa/domain/models/user_profile.dart';
import 'package:riturasa/features/profile/profile_controller.dart';

/// Modal bottom sheet allowing the user to update diet type and regional cuisine.
class EditPreferencesSheet extends ConsumerStatefulWidget {
  final UserProfile profile;

  const EditPreferencesSheet({super.key, required this.profile});

  static Future<void> show(BuildContext context, UserProfile profile) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditPreferencesSheet(profile: profile),
    );
  }

  @override
  ConsumerState<EditPreferencesSheet> createState() => _EditPreferencesSheetState();
}

class _EditPreferencesSheetState extends ConsumerState<EditPreferencesSheet> {
  late DietType _dietType;
  late String _cuisine;

  static const _dietOptions = [
    (type: DietType.vegetarian, label: 'Vegetarian (Lacto-Sattvic)'),
    (type: DietType.vegan, label: 'Vegan (Plant-Based)'),
    (type: DietType.eggetarian, label: 'Eggetarian'),
    (type: DietType.nonVegetarian, label: 'Non-Vegetarian'),
    (type: DietType.jain, label: 'Jain (No Root Veg)'),
  ];

  static const _cuisineOptions = [
    'South Indian & Coastal',
    'North Indian Punjabi & Awadhi',
    'Maharashtrian & Konkani',
    'Bengali & Eastern Indian',
    'Gujarati & Rajasthani',
  ];

  @override
  void initState() {
    super.initState();
    _dietType = widget.profile.dietType;
    _cuisine = widget.profile.cuisine.isNotEmpty ? widget.profile.cuisine : _cuisineOptions.first;
  }

  Future<void> _save() async {
    final updated = widget.profile.copyWith(
      dietType: _dietType,
      cuisine: _cuisine,
      region: _cuisine,
      updatedAt: DateTime.now(),
    );

    await ref.read(profileNotifierProvider.notifier).updateProfile(updated);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Dietary preferences saved.',
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

    return Container(
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 30,
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
                  'Diet & Regional Cuisine',
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
            const SizedBox(height: 16),

            // Diet Type Selector
            Text(
              'Dietary Pattern',
              style: GoogleFonts.outfit(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: theme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            ..._dietOptions.map((opt) {
              final isSelected = _dietType == opt.type;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: InkWell(
                  onTap: () => setState(() => _dietType = opt.type),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? theme.navBarActivePill.withValues(alpha: 0.06) : theme.screenBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? theme.navBarActivePill : theme.cardBorder,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          opt.label,
                          style: GoogleFonts.outfit(
                            fontSize: 13.5,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? theme.textPrimary : theme.textSecondary,
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle_rounded, size: 18, color: theme.navBarActivePill),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),

            // Regional Cuisine
            Text(
              'Regional Indian Cuisine Preference',
              style: GoogleFonts.outfit(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: theme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            ..._cuisineOptions.map((c) {
              final isSelected = _cuisine == c;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: InkWell(
                  onTap: () => setState(() => _cuisine = c),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? theme.navBarActivePill.withValues(alpha: 0.06) : theme.screenBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? theme.navBarActivePill : theme.cardBorder,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          c,
                          style: GoogleFonts.outfit(
                            fontSize: 13.5,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? theme.textPrimary : theme.textSecondary,
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle_rounded, size: 18, color: theme.navBarActivePill),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),

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
                  'Save Preferences',
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
