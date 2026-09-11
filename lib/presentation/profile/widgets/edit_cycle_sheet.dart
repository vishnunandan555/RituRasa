import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:riturasa/core/theme/riturasa_theme.dart';
import 'package:riturasa/features/cycle/cycle_controller.dart';

/// Modal bottom sheet allowing the user to configure and log their cycle parameters.
class EditCycleSheet extends ConsumerStatefulWidget {
  final DateTime currentPeriodStart;
  final int currentCycleLength;

  const EditCycleSheet({
    super.key,
    required this.currentPeriodStart,
    required this.currentCycleLength,
  });

  static Future<void> show(
    BuildContext context, {
    required DateTime currentPeriodStart,
    required int currentCycleLength,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditCycleSheet(
        currentPeriodStart: currentPeriodStart,
        currentCycleLength: currentCycleLength,
      ),
    );
  }

  @override
  ConsumerState<EditCycleSheet> createState() => _EditCycleSheetState();
}

class _EditCycleSheetState extends ConsumerState<EditCycleSheet> {
  late DateTime _selectedPeriodStart;
  late int _cycleLength;
  int _flowDuration = 5;

  @override
  void initState() {
    super.initState();
    _selectedPeriodStart = widget.currentPeriodStart;
    _cycleLength = widget.currentCycleLength;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedPeriodStart,
      firstDate: now.subtract(const Duration(days: 90)),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE11D48),
              onPrimary: Colors.white,
              onSurface: Color(0xFF111827),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() => _selectedPeriodStart = picked);
    }
  }

  Future<void> _save() async {
    await ref.read(cycleNotifierProvider.notifier).logPeriodStart(
          _selectedPeriodStart,
          cycleLength: _cycleLength,
          flowDuration: _flowDuration,
        );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cycle updated. Calculations refreshed across all screens.',
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
    final formattedDate = DateFormat('MMMM d, yyyy').format(_selectedPeriodStart);

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
                  'Cycle Settings & Log',
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

            // Date of Last Period Start
            Text(
              'Last Period Start Date',
              style: GoogleFonts.outfit(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: theme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.screenBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: theme.cardBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFFE11D48)),
                        const SizedBox(width: 10),
                        Text(
                          formattedDate,
                          style: GoogleFonts.outfit(
                            fontSize: 14.5,
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
                        color: const Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Average Cycle Length Stepper (21 to 40 days)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: theme.screenBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.cardBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Average Cycle Length',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: theme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Typical duration between cycles',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: theme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline_rounded),
                        onPressed: _cycleLength > 21 ? () => setState(() => _cycleLength--) : null,
                      ),
                      Text(
                        '$_cycleLength days',
                        style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline_rounded),
                        onPressed: _cycleLength < 40 ? () => setState(() => _cycleLength++) : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Period Duration Stepper (3 to 8 days)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: theme.screenBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.cardBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Period Flow Duration',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: theme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Number of bleeding days',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: theme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline_rounded),
                        onPressed: _flowDuration > 3 ? () => setState(() => _flowDuration--) : null,
                      ),
                      Text(
                        '$_flowDuration days',
                        style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline_rounded),
                        onPressed: _flowDuration < 8 ? () => setState(() => _flowDuration++) : null,
                      ),
                    ],
                  ),
                ],
              ),
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
                  'Save Cycle Settings',
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
