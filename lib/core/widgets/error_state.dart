import 'package:flutter/material.dart';

import '../../l10n/l10n_extension.dart';
import '../theme/app_radii.dart';
import '../theme/app_sizes.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/brand_colors.dart';

/// Connection / error screen — mockup 17 "Немає звʼязку".
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    this.title,
    this.subtitle,
    this.onRetry,
    this.onOffline,
  });

  final String? title;
  final String? subtitle;
  final VoidCallback? onRetry;
  final VoidCallback? onOffline;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
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
              decoration: BoxDecoration(
                color: context.colors.brandBlack,
                borderRadius: AppRadii.pillAll,
              ),
              child: Icon(Icons.wifi_off,
                  size: AppIconSize.hero, color: context.colors.brandYellow),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(title ?? l.stateOfflineTitle,
              style: AppTypography.headlineSmall, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          Text(
            subtitle ?? l.stateOfflineSubtitle,
            style: AppTypography.bodyMedium
                .copyWith(color: context.colors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(l.stateRetry),
          ),
          if (onOffline != null) ...[
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: onOffline,
              child: Text(l.stateWorkOffline),
            ),
          ],
        ],
      ),
    );
  }
}
