import 'package:flutter/material.dart';

import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/brand_colors.dart';

/// Card row for a completed service record: title + date on the left, optional
/// vehicle subtitle on the right. Pricing is intentionally absent — per
/// product rule the middleware strips prices.
class ServiceRecordTile extends StatelessWidget {
  const ServiceRecordTile({
    super.key,
    required this.title,
    required this.dateLabel,
    this.vehicleLabel,
  });

  final String title;
  final String dateLabel;

  /// e.g. "Mitsubishi Pajero" — when set, rendered as a trailing subtitle.
  /// Null when the surrounding screen already groups by vehicle.
  final String? vehicleLabel;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.titleSmall),
          const SizedBox(height: AppSpacing.xxs),
          Row(
            children: [
              Expanded(
                child: Text(
                  dateLabel,
                  style: AppTypography.bodySmall
                      .copyWith(color: context.colors.textSecondary),
                ),
              ),
              if (vehicleLabel != null && vehicleLabel!.isNotEmpty)
                Text(
                  vehicleLabel!,
                  style: AppTypography.labelMedium
                      .copyWith(color: context.colors.textSecondary),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
