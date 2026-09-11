import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:riturasa/core/theme/riturasa_theme.dart';

/// Smart Shopping List Screen
/// Automatically computes missing pantry items based on recommended
/// cycle-phase recipes and pantry inventory deficits.
class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  final List<Map<String, dynamic>> _items = [
    {
      'name': 'Fresh Organic Methi Leaves',
      'qty': '2 bunches',
      'category': 'Produce & Herbs',
      'phase': 'Period Support',
      'phaseColor': const Color(0xFFFA2C56),
      'checked': false,
    },
    {
      'name': 'Sprouted Ragi Flour (Finger Millet)',
      'qty': '1 kg',
      'category': 'Millets & Flours',
      'phase': 'Growth Phase',
      'phaseColor': const Color(0xFF4A90E2),
      'checked': false,
    },
    {
      'name': 'Organic White Sesame Seeds',
      'qty': '250 g',
      'category': 'Seeds & Superfoods',
      'phase': 'Luteal Phase',
      'phaseColor': const Color(0xFF8B5CF6),
      'checked': true,
    },
    {
      'name': 'Curry Leaves (Kadi Patta)',
      'qty': '1 bunch',
      'category': 'Produce & Herbs',
      'phase': 'Tridoshic',
      'phaseColor': const Color(0xFF10B981),
      'checked': false,
    },
    {
      'name': 'Organic Ashwagandha Powder',
      'qty': '100 g',
      'category': 'Ayurvedic Rasayanas',
      'phase': 'Peak / Vitality',
      'phaseColor': const Color(0xFFF59E0B),
      'checked': false,
    },
    {
      'name': 'A2 Desi Cow Curd / Yogurt',
      'qty': '500 g',
      'category': 'Dairy & Probiotics',
      'phase': 'Digestive Agni',
      'phaseColor': const Color(0xFF10B981),
      'checked': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = context.rituTheme;
    final uncheckedCount = _items.where((i) => !(i['checked'] as bool)).length;

    return Scaffold(
      backgroundColor: theme.screenBackground,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: 110,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Smart Grocery List',
                style: theme.screenTitleStyle,
              ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0),
              const SizedBox(height: 4),
              Text(
                'Deficit-driven from your cycle nutrition plan',
                style: theme.screenSubtitleStyle,
              ).animate().fadeIn(duration: 350.ms),

              const SizedBox(height: 18),

              // Summary Banner Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardBackground,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: theme.cardBorder, width: 1.2),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: theme.navBarActivePill,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$uncheckedCount Items Needed',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: theme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Missing ingredients for recommended recipes',
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
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 20),

              // Checklist Section
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = _items[index];
                  final isChecked = item['checked'] as bool;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        item['checked'] = !isChecked;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isChecked
                            ? theme.cardBackground.withValues(alpha: 0.6)
                            : theme.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isChecked
                              ? theme.cardBorder
                              : theme.cardBorder,
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isChecked ? theme.navBarActivePill : Colors.white,
                              border: Border.all(
                                color: isChecked
                                    ? theme.navBarActivePill
                                    : theme.cardBorder,
                                width: 2,
                              ),
                            ),
                            child: isChecked
                                ? const Icon(Icons.check_rounded, color: Colors.white, size: 15)
                                : null,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'] as String,
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: isChecked ? theme.textMuted : theme.textPrimary,
                                    decoration: isChecked
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    Text(
                                      item['qty'] as String,
                                      style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: theme.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        '•  ${item['category']}',
                                        style: GoogleFonts.outfit(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: theme.textMuted,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: (item['phaseColor'] as Color).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item['phase'] as String,
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: item['phaseColor'] as Color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: (60 * index).ms, duration: 250.ms);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
