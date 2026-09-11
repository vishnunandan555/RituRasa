import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:riturasa/core/theme/riturasa_theme.dart';
import 'package:riturasa/core/widgets/pressable_scale.dart';
import 'package:riturasa/features/cycle/cycle_controller.dart';

/// Modal bottom sheet triggered by long-pressing the main circular cycle tracker.
/// Allows the user to set their last period end date, flow duration, and cycle length,
/// dynamically recalculating the current cycle day, phase, and next cycle window.
class SetPeriodDateSheet extends ConsumerStatefulWidget {
  const SetPeriodDateSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SetPeriodDateSheet(),
    );
  }

  @override
  ConsumerState<SetPeriodDateSheet> createState() => _SetPeriodDateSheetState();
}

class _SetPeriodDateSheetState extends ConsumerState<SetPeriodDateSheet> {
  late DateTime _selectedEndDate;
  int _flowDuration = 5;
  int _cycleLength = 28;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final latestRecord = ref.read(cycleNotifierProvider).latestRecord;
    if (latestRecord != null && latestRecord.periodEnd != null) {
      _selectedEndDate = latestRecord.periodEnd!;
      _cycleLength = latestRecord.cycleLength;
      _flowDuration = latestRecord.periodEnd!.difference(latestRecord.periodStart).inDays + 1;
      if (_flowDuration < 3 || _flowDuration > 8) _flowDuration = 5;
    } else {
      // Default: period ended 6 days ago (putting user at Day 11)
      _selectedEndDate = DateTime.now().subtract(const Duration(days: 6));
    }
  }

  DateTime get _calculatedStartDate {
    return _selectedEndDate.subtract(Duration(days: _flowDuration - 1));
  }

  int get _calculatedCycleDay {
    final now = DateTime.now();
    final startMidnight = DateTime(_calculatedStartDate.year, _calculatedStartDate.month, _calculatedStartDate.day);
    final nowMidnight = DateTime(now.year, now.month, now.day);
    final diff = nowMidnight.difference(startMidnight).inDays;
    if (diff < 0) return 1;
    return (diff % _cycleLength) + 1;
  }

  String get _calculatedPhase {
    final day = _calculatedCycleDay;
    if (day <= _flowDuration) return 'Period';
    if (day <= 13) return 'Growth';
    if (day <= 16) return 'Peak';
    return 'Luteal';
  }

  Color _getPhaseColor(String phase, RituRasaThemeExtension theme) {
    switch (phase) {
      case 'Period':
        return theme.periodColor;
      case 'Growth':
        return theme.growthColor;
      case 'Peak':
        return theme.peakColor;
      case 'Luteal':
      default:
        return theme.lutealColor;
    }
  }

  String get _calculatedNextWindow {
    final day = _calculatedCycleDay;
    final daysUntilNext = _cycleLength - day;
    final targetDate = DateTime.now().add(Duration(days: daysUntilNext));
    final startWindow = targetDate.subtract(const Duration(days: 1));
    final endWindow = targetDate.add(const Duration(days: 1));

    if (startWindow.month == endWindow.month) {
      final month = DateFormat('MMMM').format(startWindow);
      return '$month ${startWindow.day} – ${endWindow.day}, ${startWindow.year}';
    } else {
      final m1 = DateFormat('MMM').format(startWindow);
      final m2 = DateFormat('MMM').format(endWindow);
      return '$m1 ${startWindow.day} – $m2 ${endWindow.day}, ${endWindow.year}';
    }
  }

  Future<void> _pickCustomDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate.isAfter(now) ? now : _selectedEndDate,
      firstDate: now.subtract(const Duration(days: 120)),
      lastDate: now,
      helpText: 'SELECT LAST PERIOD END DATE',
      confirmText: 'SELECT',
    );

    if (picked != null) {
      setState(() => _selectedEndDate = picked);
    }
  }

  Future<void> _saveAndRecalculate() async {
    setState(() => _isSubmitting = true);
    HapticFeedback.mediumImpact();

    await ref.read(cycleNotifierProvider.notifier).logPeriodEnd(
          _selectedEndDate,
          flowDuration: _flowDuration,
          cycleLength: _cycleLength,
        );

    if (mounted) {
      setState(() => _isSubmitting = false);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cycle updated! Currently at Day $_calculatedCycleDay ($_calculatedPhase Phase).',
            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.rituTheme;
    final phaseName = _calculatedPhase;
    final phaseColor = _getPhaseColor(phaseName, theme);
    final day = _calculatedCycleDay;

    return Container(
      decoration: BoxDecoration(
        color: theme.screenBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: theme.screenPadding,
            vertical: 18,
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

              // Title Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Set Last Period Date',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: theme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Everything is automatically calculated from this date',
                          style: GoogleFonts.outfit(
                            fontSize: 12.5,
                            color: theme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: theme.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 1. Live Calculation Preview Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      phaseColor.withValues(alpha: 0.12),
                      phaseColor.withValues(alpha: 0.04),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: phaseColor.withValues(alpha: 0.3), width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: phaseColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Calculated Cycle Day Today',
                              style: GoogleFonts.outfit(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: theme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: phaseColor.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$phaseName Phase',
                            style: GoogleFonts.outfit(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: phaseColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'Day $day',
                          style: GoogleFonts.outfit(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: theme.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          ' / $_cycleLength days',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: theme.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Divider(color: phaseColor.withValues(alpha: 0.2), height: 1),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_month_rounded, size: 15, color: phaseColor),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Next Window: $_calculatedNextWindow',
                            style: GoogleFonts.outfit(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: theme.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2. Last Period End Date Picker
              Text(
                'When did your last period end?',
                style: GoogleFonts.outfit(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: theme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _pickCustomDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: theme.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.cardBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.event_available_rounded, color: theme.navBarActivePill, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat('EEEE, MMMM d, yyyy').format(_selectedEndDate),
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: theme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Change',
                        style: GoogleFonts.outfit(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: theme.navBarActivePill,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Quick presets for end date
              Row(
                children: [
                  _buildQuickPresetChip('Today', 0),
                  const SizedBox(width: 8),
                  _buildQuickPresetChip('Yesterday', 1),
                  const SizedBox(width: 8),
                  _buildQuickPresetChip('4 days ago', 4),
                  const SizedBox(width: 8),
                  _buildQuickPresetChip('7 days ago', 7),
                ],
              ),

              const SizedBox(height: 20),

              // 3. Flow Duration & Cycle Length Steppers
              Row(
                children: [
                  // Flow Duration
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Flow Duration',
                            style: GoogleFonts.outfit(fontSize: 11.5, color: theme.textSecondary),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, size: 20),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: _flowDuration > 3 ? () => setState(() => _flowDuration--) : null,
                              ),
                              Text(
                                '$_flowDuration days',
                                style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, size: 20),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: _flowDuration < 8 ? () => setState(() => _flowDuration++) : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Cycle Length
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cycle Length',
                            style: GoogleFonts.outfit(fontSize: 11.5, color: theme.textSecondary),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, size: 20),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: _cycleLength > 21 ? () => setState(() => _cycleLength--) : null,
                              ),
                              Text(
                                '$_cycleLength days',
                                style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, size: 20),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: _cycleLength < 40 ? () => setState(() => _cycleLength++) : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 4. Save & Recalculate CTA
              PressableScale(
                onTap: _isSubmitting ? null : _saveAndRecalculate,
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
                      const Icon(Icons.check_rounded, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        _isSubmitting ? 'Saving...' : 'Save & Recalculate Cycle',
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
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickPresetChip(String label, int daysAgo) {
    final targetDate = DateTime.now().subtract(Duration(days: daysAgo));
    final isSelected = _selectedEndDate.year == targetDate.year &&
        _selectedEndDate.month == targetDate.month &&
        _selectedEndDate.day == targetDate.day;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          setState(() => _selectedEndDate = targetDate);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? context.rituTheme.navBarActivePill : context.rituTheme.cardBackground,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? context.rituTheme.navBarActivePill : context.rituTheme.cardBorder,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected ? Colors.white : context.rituTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
