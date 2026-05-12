import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Surface card with a muted label + emphasized value.
/// [Axis.horizontal] puts label on the left, value on the right.
/// [Axis.vertical] stacks label above value (used in detail "stat grid" cells).
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.axis = Axis.horizontal,
  });

  final String label;
  final String value;
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    final labelStyle =
        AppTypography.bodySmall.copyWith(color: AppColors.textSecondary);
    final valueStyle = AppTypography.titleSmall;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: switch (axis) {
        Axis.horizontal => Row(
            children: [
              Expanded(child: Text(label, style: labelStyle)),
              Text(value, style: valueStyle),
            ],
          ),
        Axis.vertical => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: labelStyle),
              const SizedBox(height: AppSpacing.xxs),
              Text(value, style: valueStyle),
            ],
          ),
      },
    );
  }
}
