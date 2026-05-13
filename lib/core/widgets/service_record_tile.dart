import 'package:flutter/material.dart';

import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/brand_colors.dart';

/// Card row for a completed service record: title + date on the left,
/// price on the right. Shared by HistoryScreen + CarDetail's "ОСТАННІ
/// РОБОТИ" section.
class ServiceRecordTile extends StatelessWidget {
  const ServiceRecordTile({
    super.key,
    required this.title,
    required this.dateLabel,
    required this.priceUah,
  });

  final String title;
  final String dateLabel;
  final int priceUah;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: context.colors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.titleSmall),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  dateLabel,
                  style: AppTypography.bodySmall
                      .copyWith(color: context.colors.textSecondary),
                ),
              ],
            ),
          ),
          Text('$priceUah ₴', style: AppTypography.labelLarge),
        ],
      ),
    );
  }
}
