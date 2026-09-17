import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  IconData _getCategoryIcon(String name) {
    switch (name.toLowerCase()) {
      case 'all':
        return Icons.grid_view_rounded;
      case 'technology':
        return Icons.devices_rounded;
      case 'music':
        return Icons.music_note_rounded;
      case 'food & drinks':
        return Icons.restaurant_rounded;
      case 'sports':
        return Icons.sports_basketball_rounded;
      case 'arts & culture':
        return Icons.palette_rounded;
      case 'business':
        return Icons.business_center_rounded;
      default:
        return Icons.local_activity_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primary
                  : (isDark ? AppTheme.surfaceDark : Colors.white),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primary
                    : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
                width: 1.2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getCategoryIcon(label),
                  size: 16,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white70 : AppTheme.textSecondaryLight),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white : AppTheme.textPrimaryLight),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
