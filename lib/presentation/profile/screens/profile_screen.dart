import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:riturasa/core/theme/riturasa_theme.dart';

/// User Profile & Health Settings Screen conforming to nutrition_flutter_ui_5_screen_srs.md.
/// Displays user biological profile, cycle parameters, dietary exclusions,
/// and local data controls (Export / Reset data).
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final String _dietType = 'Vegetarian (Lacto-Sattvic)';
  final String _cuisine = 'South Indian & Coastal';
  final int _cycleLength = 28;
  final int _periodDuration = 5;
  final String _lastPeriodDate = 'May 30, 2026';

  final List<String> _favoriteFoods = ['Spinach', 'Moong Dal', 'Ragi', 'Ghee', 'Pomegranate'];
  final List<String> _exclusions = ['Excess Red Chili', 'Deep Fried Snacks', 'Refined Sugar'];

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.file_download_done_rounded, color: Color(0xFF10B981), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Personal cycle and meal history exported locally as JSON.',
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          'This will erase all logged meals, pantry inventory, and cycle logs stored locally on this device.',
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
            onPressed: () {
              Navigator.pop(ctx);
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

              // User Bio Card
              Container(
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
                        'AS',
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
                          Text(
                            'Ananya Sharma',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: theme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Pitta-Vata Prakriti • 28 yrs',
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
                              'Cycle Day 12 • Peak Phase',
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
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 20),

              // Cycle Parameters Card
              Text(
                'Cycle Information',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: theme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  _buildStatTile(context, 'Avg Cycle', '$_cycleLength Days', Icons.calendar_today_rounded),
                  SizedBox(width: theme.isCompact ? 6 : 10),
                  _buildStatTile(context, 'Period Flow', '$_periodDuration Days', Icons.water_drop_outlined),
                  SizedBox(width: theme.isCompact ? 6 : 10),
                  _buildStatTile(context, 'Last Period', _lastPeriodDate, Icons.event_available_rounded),
                ],
              ).animate().fadeIn(duration: 450.ms),

              const SizedBox(height: 22),

              // Dietary & Regional Preferences
              Text(
                'Dietary & Regional Preferences',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: theme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardBackground,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: theme.cardBorder, width: 1.2),
                ),
                child: Column(
                  children: [
                    _buildPrefRow(context, 'Diet Type', _dietType),
                    const Divider(height: 24, thickness: 0.8),
                    _buildPrefRow(context, 'Regional Focus', _cuisine),
                    const Divider(height: 24, thickness: 0.8),
                    _buildPrefRow(context, 'Ayurvedic Agni', 'Tikshna (Fast Digestion)'),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms),

              const SizedBox(height: 22),

              // Food Preferences: Favorites & Exclusions
              Text(
                'Food Preferences & Exclusions',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: theme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

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
                    Text(
                      'Favorite Foods',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: theme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _favoriteFoods.map((f) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            f,
                            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF047857)),
                          ),
                        );
                      }).toList(),
                    ),
                    const Divider(height: 24, thickness: 0.8),
                    Text(
                      'Dietary Exclusions / Dislikes',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: theme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _exclusions.map((e) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE11D48).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE11D48).withValues(alpha: 0.25)),
                          ),
                          child: Text(
                            e,
                            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFFBE123C)),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
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
              ).animate().fadeIn(duration: 550.ms),

              const SizedBox(height: 22),

              // About App Card with Logo
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: theme.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.cardBorder, width: 1.2),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: theme.cardBorder),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                            errorBuilder: (ctx, err, stack) => const Icon(Icons.spa_rounded, size: 28),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'RituRasa',
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: theme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Version 1.0.0 • Ayurvedic Cycle Syncing',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: theme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Harmonizing biological menstrual cycles with authentic Ayurvedic wisdom and modern nutritional science.',
                      style: GoogleFonts.outfit(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                        color: theme.textSecondary,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showAppAboutDialog(context),
                        icon: const Icon(Icons.info_outline_rounded, size: 16),
                        label: Text(
                          'About & Legal Info',
                          style: GoogleFonts.outfit(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.textPrimary,
                          side: BorderSide(color: theme.cardBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms),
            ],
          ),
        ),
      ),
    );
  }

  void _showAppAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'RituRasa',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 48,
        height: 48,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Image.asset('assets/images/logo.png', errorBuilder: (ctx, err, stack) => const Icon(Icons.spa_rounded, size: 28)),
      ),
      applicationLegalese: '© 2026 RituRasa. All rights reserved.\nAyurvedic Cycle & Nutrition Engine.',
    );
  }

  Widget _buildStatTile(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = context.rituTheme;
    final isCompact = theme.isCompact;
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 6 : 10,
          vertical: isCompact ? 8 : 12,
        ),
        decoration: BoxDecoration(
          color: theme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.cardBorder),
        ),
        child: Column(
          children: [
            Icon(icon, size: isCompact ? 18 : 20, color: theme.textSecondary),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: isCompact ? 12 : 13,
                  fontWeight: FontWeight.w800,
                  color: theme.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: isCompact ? 9.5 : 10,
                  fontWeight: FontWeight.w500,
                  color: theme.textMuted,
                ),
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
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: theme.textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.outfit(
              fontSize: 13,
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
