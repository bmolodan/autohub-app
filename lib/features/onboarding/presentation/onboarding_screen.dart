import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/brand_colors.dart';
import '../../../l10n/l10n_extension.dart';

/// Three-slide intro shown only on first launch.
///
/// For now this is a one-slide placeholder so the navigation chain works
/// end-to-end. Slide content and PageView are wired in the next iteration.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => context.go(AppRoutes.phone),
                  child: Text(context.l10n.onboardingSkip),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Hero illustration placeholder (replace with photo / Lottie later)
              Container(
                height: 220,
                decoration: BoxDecoration(
                  color: context.colors.brandBlack,
                  borderRadius: AppRadii.xlAll,
                ),
                child: Center(
                  child: Icon(
                    Icons.calendar_month_outlined,
                    color: context.colors.brandYellow,
                    size: 64,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              Text(
                context.l10n.onboardingTitle,
                style: AppTypography.headlineLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                context.l10n.onboardingSubtitle,
                style: AppTypography.bodyLarge.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),

              const Spacer(),

              // Pagination dots (static for the placeholder)
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _Dot(active: true),
                  SizedBox(width: AppSpacing.xs),
                  _Dot(),
                  SizedBox(width: AppSpacing.xs),
                  _Dot(),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              FilledButton(
                onPressed: () => context.go(AppRoutes.phone),
                child: Text(context.l10n.commonNext),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool active;
  const _Dot({this.active = false});

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: active ? 24 : 5,
        height: 5,
        decoration: BoxDecoration(
          color: active ? context.colors.brandBlack : context.colors.borderStrong,
          borderRadius: AppRadii.pillAll,
        ),
      );
}
