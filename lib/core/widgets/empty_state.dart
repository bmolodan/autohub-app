import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Centered illustration + title + subtitle + optional CTA.
/// Mockup 16 — "Поки тиша" empty state.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.ctaLabel,
    this.onCta,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? ctaLabel;
  final VoidCallback? onCta;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: AppColors.brandYellowSoft,
                borderRadius: AppRadii.pillAll,
              ),
              child: Icon(icon, size: 36, color: AppColors.brandBlack),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(title,
              style: AppTypography.headlineSmall, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          Text(
            subtitle,
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          if (ctaLabel != null) ...[
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(onPressed: onCta, child: Text(ctaLabel!)),
          ],
        ],
      ),
    );
  }
}
