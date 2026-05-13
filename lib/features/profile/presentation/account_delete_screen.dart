import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/l10n_extension.dart';
import '../composition/profile_providers.dart';

/// Mockup 18 — destructive confirm. Signs out; full data wipe is a follow-up.
class AccountDeleteScreen extends ConsumerWidget {
  const AccountDeleteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final willDelete = [
      l.accountDeleteItemProfile,
      l.accountDeleteItemHistory,
      l.accountDeleteItemPush,
    ];
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(l.accountDeleteTitle, style: AppTypography.titleLarge),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.md),
              Center(
                child: Container(
                  width: AppSizes.iconBubble,
                  height: AppSizes.iconBubble,
                  decoration: const BoxDecoration(
                    color: AppColors.errorSoft,
                    borderRadius: AppRadii.lgAll,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    size: AppIconSize.hero,
                    color: AppColors.error,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(l.accountDeleteHeading, style: AppTypography.headlineMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l.accountDeleteBody,
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.md),
              for (final item in willDelete) _DeleteItem(label: item),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: const BoxDecoration(
                  color: AppColors.brandYellowSoft,
                  borderRadius: AppRadii.mdAll,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline,
                        size: AppIconSize.sm, color: AppColors.brandBlack),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        l.accountDeleteLegalNote,
                        style: AppTypography.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.onError,
                ),
                onPressed: () async {
                  // Wipe order: photos → orders → vehicles → profile →
                  // session (router redirect kicks in once session clears).
                  await ref.read(wipeAccountUseCaseProvider).execute();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l.accountDeleteSuccessSnack)),
                  );
                  context.go(AppRoutes.onboarding);
                },
                child: Text(l.accountDeleteConfirm),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                onPressed: () => context.pop(),
                child: Text(l.commonCancel),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeleteItem extends StatelessWidget {
  const _DeleteItem({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.close, color: AppColors.error, size: AppIconSize.sm),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(label, style: AppTypography.titleSmall)),
        ],
      ),
    );
  }
}
