import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Connection / error screen — mockup 17 "Немає звʼязку".
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    this.title = 'Немає звʼязку',
    this.subtitle = 'Перевірте інтернет-зʼєднання — і ми спробуємо ще раз.',
    this.onRetry,
    this.onOffline,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onRetry;
  final VoidCallback? onOffline;

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
                color: AppColors.brandBlack,
                borderRadius: AppRadii.pillAll,
              ),
              child: const Icon(Icons.wifi_off,
                  size: 36, color: AppColors.brandYellow),
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
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Спробувати знову'),
          ),
          if (onOffline != null) ...[
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: onOffline,
              child: const Text('Працювати офлайн'),
            ),
          ],
        ],
      ),
    );
  }
}
