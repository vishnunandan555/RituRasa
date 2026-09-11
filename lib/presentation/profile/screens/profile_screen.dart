import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:riturasa/core/database/database_manager.dart';
import 'package:riturasa/core/database/initial_data_seeder.dart';
import 'package:riturasa/core/theme/riturasa_theme.dart';
import 'package:riturasa/features/cycle/cycle_controller.dart';
import 'package:riturasa/features/profile/profile_controller.dart';
import 'package:riturasa/presentation/profile/widgets/edit_cycle_sheet.dart';
import 'package:riturasa/presentation/profile/widgets/edit_preferences_sheet.dart';
import 'package:riturasa/presentation/profile/widgets/edit_profile_sheet.dart';
import 'package:riturasa/presentation/profile/widgets/manage_food_preferences_sheet.dart';

/// User Profile & Health Settings Screen conforming to nutrition_flutter_ui_5_screen_srs.md.
/// Displays user biological profile, cycle parameters, dietary exclusions,
/// and local data controls (Export / Reset data), backed by authoritative SQLite storage.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Future<void> _exportData() async {
    final dbRes = await DatabaseManager.instance.getUserDatabase();
    final db = dbRes.valueOrNull;
    if (db == null) return;

    final profiles = await db.query('user_profile');
    final prefs = await db.query('user_preferences');
    final cycles = await db.query('cycle_history');
    final kitchen = await db.query('kitchen_inventory');
    final shopping = await db.query('shopping_list');

    final exportJson = {
      'exported_at': DateTime.now().toIso8601String(),
      'app_version': '1.0.0',
      'user_profile': profiles,
      'user_preferences': prefs,
      'cycle_history': cycles,
      'kitchen_inventory': kitchen,
      'shopping_list': shopping,
    };

    final formatted = const JsonEncoder.withIndent('  ').convert(exportJson);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.file_download_done_rounded, color: Color(0xFF10B981), size: 22),
            const SizedBox(width: 8),
            Text(
              'Export Local Data',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: SingleChildScrollView(
            child: SelectableText(
              formatted,
              style: GoogleFonts.firaCode(fontSize: 11, color: const Color(0xFF334155)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Close', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF18181B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: Text('Copy JSON', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: formatted));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Exported data copied to clipboard.',
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
                  ),
                  backgroundColor: const Color(0xFF10B981),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _confirmResetData() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Reset Local Data?',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        content: Text(
          'This will erase all logged meals, pantry inventory, and cycle logs stored locally and restore default initial starter data.',
          style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE11D48),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await InitialDataSeeder(DatabaseManager.instance).resetToDefaults();
              await ref.read(profileNotifierProvider.notifier).loadProfile();
              await ref.read(cycleNotifierProvider.notifier).loadCycle();

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'App data has been reset to defaults.',
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
                    ),
                    backgroundColor: const Color(0xFFE11D48),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text('Reset', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.rituTheme;
    final profileState = ref.watch(profileNotifierProvider);
    final cycleState = ref.watch(cycleNotifierProvider);

    final profile = profileState.profile;
    final preferences = profileState.preferences;
    final cycleRecord = cycleState.latestRecord;
    final cycleDayState = cycleState.currentState;

    // Derived values with sensible fallbacks
    final name = profile?.name ?? 'Ananya Sharma';
    final age = profile?.age ?? 28;
    final prakriti = profile?.prakriti ?? 'Pitta-Vata';
    final agni = profile?.agni ?? 'Tikshna';
    final dietType = profile?.dietType.name.toUpperCase() ?? 'VEGETARIAN';
    final cuisine = profile?.cuisine ?? 'South Indian & Coastal';

    final cycleLength = cycleRecord?.cycleLength ?? 28;
    final lastPeriodDate = cycleRecord != null
        ? DateFormat('MMM d, yyyy').format(cycleRecord.periodStart)
        : 'May 30, 2026';
    final currentDay = cycleDayState?.currentCycleDay ?? 12;
    final phaseName = cycleDayState?.phaseInfo.phaseName.toUpperCase() ?? 'PEAK';

    final allergies = preferences?.allergies ?? ['Peanuts', 'Excess Red Chili'];

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
              // Header
              Text(
                'My Profile',
                style: theme.screenTitleStyle,
              ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0),
              const SizedBox(height: 4),
              Text(
                'Personalization, cycle parameters & data controls',
                style: theme.screenSubtitleStyle,
              ).animate().fadeIn(duration: 350.ms),

              const SizedBox(height: 18),

              // User Bio Card (Tappable to edit)
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: profile != null
                    ? () => EditProfileSheet.show(context, profile)
                    : null,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: theme.cardBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.cardBorder, width: 1.2),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: theme.peakColor.withValues(alpha: 0.15),
                        child: Text(
                          name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'A',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: theme.peakColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    name,
                                    style: GoogleFonts.outfit(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: theme.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Icon(Icons.edit_outlined, size: 16, color: theme.textSecondary),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '$prakriti Prakriti • $age yrs',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: theme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.peakColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Cycle Day $currentDay • $phaseName Phase',
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: theme.peakColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 20),

              // Cycle Parameters Card
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Cycle Information',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: theme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () => EditCycleSheet.show(
                      context,
                      currentPeriodStart: cycleRecord?.periodStart ?? DateTime.now(),
                      currentCycleLength: cycleLength,
                    ),
                    child: Text(
                      'Edit',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: theme.navBarActivePill,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => EditCycleSheet.show(
                  context,
                  currentPeriodStart: cycleRecord?.periodStart ?? DateTime.now(),
                  currentCycleLength: cycleLength,
                ),
                child: Row(
                  children: [
                    _buildStatTile(context, 'Avg Cycle', '$cycleLength Days', Icons.calendar_today_rounded),
                    SizedBox(width: theme.isCompact ? 6 : 10),
                    _buildStatTile(context, 'Period Flow', '5 Days', Icons.water_drop_outlined),
                    SizedBox(width: theme.isCompact ? 6 : 10),
                    _buildStatTile(context, 'Last Period', lastPeriodDate, Icons.event_available_rounded),
                  ],
                ),
              ).animate().fadeIn(duration: 450.ms),

              const SizedBox(height: 22),

              // Dietary & Regional Preferences
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Dietary & Regional Preferences',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: theme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (profile != null)
                    TextButton(
                      onPressed: () => EditPreferencesSheet.show(context, profile),
                      child: Text(
                        'Edit',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: theme.navBarActivePill,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: profile != null ? () => EditPreferencesSheet.show(context, profile) : null,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardBackground,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: theme.cardBorder, width: 1.2),
                  ),
                  child: Column(
                    children: [
                      _buildPrefRow(context, 'Diet Type', dietType),
                      const Divider(height: 24, thickness: 0.8),
                      _buildPrefRow(context, 'Regional Focus', cuisine),
                      const Divider(height: 24, thickness: 0.8),
                      _buildPrefRow(context, 'Ayurvedic Agni', '$agni (Digestion)'),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 500.ms),

              const SizedBox(height: 22),

              // Food Preferences: Favorites & Exclusions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Dietary Exclusions & Allergies',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: theme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (preferences != null)
                    TextButton(
                      onPressed: () => ManageFoodPreferencesSheet.show(context, preferences),
                      child: Text(
                        'Manage',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: theme.navBarActivePill,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: preferences != null ? () => ManageFoodPreferencesSheet.show(context, preferences) : null,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardBackground,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: theme.cardBorder, width: 1.2),
                  ),
                  child: allergies.isEmpty
                      ? Text(
                          'No exclusions logged. Tap to manage.',
                          style: GoogleFonts.outfit(fontSize: 13, color: theme.textSecondary),
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: allergies.map((e) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE11D48).withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE11D48).withValues(alpha: 0.25)),
                              ),
                              child: Text(
                                e,
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFBE123C),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ),
              ).animate().fadeIn(duration: 520.ms),

              const SizedBox(height: 22),

              // Data Controls Card (SRS requirement)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardBackground,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: theme.cardBorder, width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.shield_outlined, size: 20, color: Color(0xFF10B981)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Your personal data is stored locally',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: theme.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'All menstrual dates, symptoms, pantry items, and nutritional intake remain 100% on this device with zero cloud tracking.',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: theme.textSecondary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _exportData,
                            icon: const Icon(Icons.download_rounded, size: 16),
                            label: Text(
                              'Export Data',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 12.5),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: theme.textPrimary,
                              side: BorderSide(color: theme.cardBorder),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _confirmResetData,
                            icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFE11D48)),
                            label: Text(
                              'Reset Data',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 12.5, color: const Color(0xFFE11D48)),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: const Color(0xFFE11D48).withValues(alpha: 0.3)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 540.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatTile(BuildContext context, String label, String value, IconData icon) {
    final theme = context.rituTheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: theme.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.cardBorder),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: theme.textSecondary),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: theme.textPrimary,
                ),
                maxLines: 1,
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: theme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrefRow(BuildContext context, String title, String value) {
    final theme = context.rituTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: theme.textSecondary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.outfit(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: theme.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
