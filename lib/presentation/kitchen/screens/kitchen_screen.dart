import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:riturasa/core/theme/riturasa_theme.dart';

/// Kitchen & Pantry Screen
/// Allows managing pantry inventory, tracking shelf life,
/// and filtering ingredients with Ayurvedic & cycle phase tags.
class KitchenScreen extends StatefulWidget {
  const KitchenScreen({super.key});

  @override
  State<KitchenScreen> createState() => _KitchenScreenState();
}

class _KitchenScreenState extends State<KitchenScreen> {
  int _selectedCategoryIndex = 0;
  final List<String> _categories = [
    'All Items',
    'Grains & Millets',
    'Dals & Pulses',
    'Spices & Herbs',
    'Oils & Ghee',
  ];

  final List<Map<String, dynamic>> _sampleItems = [
    {
      'name': 'Ragi Flour (Finger Millet)',
      'qty': '1.2 kg',
      'tag': 'Growth Phase',
      'tagColor': const Color(0xFF4A90E2),
      'benefit': 'Rich in calcium & bioavailable iron',
      'status': 'In Stock',
      'icon': Icons.grain_rounded,
    },
    {
      'name': 'Organic Yellow Moong Dal',
      'qty': '850 g',
      'tag': 'Tridoshic',
      'tagColor': const Color(0xFF10B981),
      'benefit': 'Easy to digest protein for all phases',
      'status': 'In Stock',
      'icon': Icons.eco_rounded,
    },
    {
      'name': 'Black Sesame Seeds (Til)',
      'qty': '200 g',
      'tag': 'Luteal Phase',
      'tagColor': const Color(0xFF8B5CF6),
      'benefit': 'Rich in zinc & healthy hormonal lipids',
      'status': 'In Stock',
      'icon': Icons.scatter_plot_rounded,
    },
    {
      'name': 'Organic Whole Methi Seeds',
      'qty': '60 g',
      'tag': 'Period Support',
      'tagColor': const Color(0xFFFA2C56),
      'benefit': 'Anti-spasmodic cramps relief',
      'status': 'Low Stock',
      'icon': Icons.spa_rounded,
    },
    {
      'name': 'Bilona A2 Desi Cow Ghee',
      'qty': '450 ml',
      'tag': 'Ojas Builder',
      'tagColor': const Color(0xFFF59E0B),
      'benefit': 'Enhances nutrient absorption & hormone balance',
      'status': 'In Stock',
      'icon': Icons.water_drop_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = context.rituTheme;

    return Scaffold(
      backgroundColor: theme.screenBackground,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: 110, // Avoid overlap with floating nav bar
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Kitchen & Pantry',
                style: theme.screenTitleStyle,
              ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0),
              const SizedBox(height: 4),
              Text(
                'Available ingredients & phase compatibility',
                style: theme.screenSubtitleStyle,
              ).animate().fadeIn(duration: 350.ms),

              const SizedBox(height: 18),

              // Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.cardBorder, width: 1.2),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, color: theme.textMuted, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search millets, dals, spices...',
                          hintStyle: GoogleFonts.outfit(
                            fontSize: 14,
                            color: theme.textMuted,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 18),

              // Quick Metric Chips Row
              Row(
                children: [
                  _buildMetricPill(context, 'Total Items', '24', Icons.inventory_2_outlined),
                  const SizedBox(width: 10),
                  _buildMetricPill(context, 'Expiring Soon', '2', Icons.timer_outlined, alert: true),
                  const SizedBox(width: 10),
                  _buildMetricPill(context, 'Herbs', '8', Icons.spa_outlined),
                ],
              ).animate().fadeIn(duration: 450.ms),

              const SizedBox(height: 20),

              // Category Selector
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final isSelected = index == _selectedCategoryIndex;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategoryIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? theme.chipSelectedBg : theme.chipUnselectedBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            _categories[index],
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? theme.chipSelectedText : theme.chipUnselectedText,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Item Cards List
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _sampleItems.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = _sampleItems[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardBackground,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: theme.cardBorder, width: 1.2),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: theme.cardBorder),
                          ),
                          child: Icon(item['icon'] as IconData, color: theme.textPrimary, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item['name'] as String,
                                      style: theme.cardTitleStyle,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    item['qty'] as String,
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: theme.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['benefit'] as String,
                                style: theme.cardSubtitleStyle,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: (item['tagColor'] as Color).withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        item['tag'] as String,
                                        style: GoogleFonts.outfit(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: item['tagColor'] as Color,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    item['status'] as String,
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: item['status'] == 'Low Stock'
                                          ? const Color(0xFFE11D48)
                                          : const Color(0xFF059669),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: (100 * index).ms, duration: 300.ms);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricPill(
    BuildContext context,
    String label,
    String count,
    IconData icon, {
    bool alert = false,
  }) {
    final theme = context.rituTheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: theme.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.cardBorder),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: alert ? const Color(0xFFE11D48) : theme.textSecondary,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    count,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: theme.textPrimary,
                    ),
                  ),
                  Text(
                    label,
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: theme.textMuted,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
