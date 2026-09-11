import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:riturasa/core/theme/riturasa_theme.dart';
import 'package:riturasa/domain/models/user_profile.dart';
import 'package:riturasa/features/profile/profile_controller.dart';

/// Modal bottom sheet allowing the user to update their personal biological & Ayurvedic profile.
class EditProfileSheet extends ConsumerStatefulWidget {
  final UserProfile profile;

  const EditProfileSheet({super.key, required this.profile});

  static Future<void> show(BuildContext context, UserProfile profile) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditProfileSheet(profile: profile),
    );
  }

  @override
  ConsumerState<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<EditProfileSheet> {
  late final TextEditingController _nameController;
  late int _age;
  late String _prakriti;
  late String _agni;

  static const _prakritiOptions = [
    'Pitta-Vata',
    'Pitta-Kapha',
    'Vata-Kapha',
    'Pitta',
    'Vata',
    'Kapha',
    'Tridoshic',
  ];

  static const _agniOptions = [
    'Tikshna', // Sharp / High metabolism
    'Sama', // Balanced
    'Manda', // Slow / Sluggish
    'Vishama', // Irregular / Fluctuating
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _age = widget.profile.age;
    _prakriti = widget.profile.prakriti;
    _agni = widget.profile.agni;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final updated = widget.profile.copyWith(
      name: name,
      age: _age,
      prakriti: _prakriti,
      agni: _agni,
      updatedAt: DateTime.now(),
    );

    await ref.read(profileNotifierProvider.notifier).updateProfile(updated);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Profile updated successfully.',
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
            // Handle bar
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
                  'Edit Biological Profile',
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

            // Name field
            Text(
              'Full Name',
              style: GoogleFonts.outfit(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: theme.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              style: GoogleFonts.outfit(fontSize: 14, color: theme.textPrimary),
              decoration: InputDecoration(
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
            const SizedBox(height: 16),

            // Age Stepper
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Age: $_age yrs',
                  style: GoogleFonts.outfit(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: theme.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline_rounded),
                      onPressed: _age > 15 ? () => setState(() => _age--) : null,
                    ),
                    Text('$_age', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline_rounded),
                      onPressed: _age < 75 ? () => setState(() => _age++) : null,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Prakriti / Dosha
            Text(
              'Ayurvedic Prakriti (Constitution)',
              style: GoogleFonts.outfit(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: theme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _prakritiOptions.map((p) {
                final isSelected = _prakriti.toLowerCase() == p.toLowerCase();
                return ChoiceChip(
                  label: Text(p),
                  selected: isSelected,
                  labelStyle: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : theme.textPrimary,
                  ),
                  selectedColor: theme.navBarActivePill,
                  backgroundColor: theme.screenBackground,
                  onSelected: (selected) {
                    if (selected) setState(() => _prakriti = p);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Agni (Digestive Fire)
            Text(
              'Agni (Digestive Fire)',
              style: GoogleFonts.outfit(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: theme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _agniOptions.map((a) {
                final isSelected = _agni.toLowerCase() == a.toLowerCase();
                return ChoiceChip(
                  label: Text(a),
                  selected: isSelected,
                  labelStyle: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : theme.textPrimary,
                  ),
                  selectedColor: theme.navBarActivePill,
                  backgroundColor: theme.screenBackground,
                  onSelected: (selected) {
                    if (selected) setState(() => _agni = a);
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
                  'Save Profile',
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
