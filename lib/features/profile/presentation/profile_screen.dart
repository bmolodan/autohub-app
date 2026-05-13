import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/brand_colors.dart';
import '../../../l10n/l10n_extension.dart';
import '../../auth/composition/auth_providers.dart';
import '../../cars/composition/cars_providers.dart';
import '../../cars/domain/vehicle.dart';
import '../composition/profile_providers.dart';

/// Mockup 09 — user profile.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(vehiclesControllerProvider);
    final session = ref.watch(authControllerProvider).asData?.value;
    final profile = ref.watch(clientProfileControllerProvider).asData?.value;
    // Session is guaranteed non-null inside the shell (router redirects
    // unauthenticated users to /onboarding before they can land here).
    final phone = session?.phone ?? '—';
    final name = profile?.name ?? '';

    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.profileTitle, style: AppTypography.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: l.profileEditSemantics,
            onPressed: () => context.push(AppRoutes.profileEdit),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          children: [
            _UserHeader(name: name, phone: phone, email: profile?.email),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l.profileMyCars,
              style: AppTypography.overline
                  .copyWith(color: context.colors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.sm),
            async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) =>
                  Text(l.errorGeneric, style: AppTypography.bodyMedium),
              data: (cars) => Column(
                children: [
                  for (final car in cars) _VehicleSummary(vehicle: car),
                  const SizedBox(height: AppSpacing.xxs),
                  OutlinedButton.icon(
                    onPressed: () => context.push(AppRoutes.carAdd),
                    icon: const Icon(Icons.add),
                    label: Text(l.carsAddCta),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _SettingsRow(
              icon: Icons.notifications_outlined,
              label: l.profileNotifications,
              onTap: () => context.push(AppRoutes.profileNotifications),
            ),
            _SettingsRow(
              icon: Icons.language_outlined,
              label: l.profileLanguage,
              trailing: l.profileLanguageBadge,
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l.profileLanguageTodo)),
              ),
            ),
            _SettingsRow(
              icon: Icons.support_agent_outlined,
              label: l.profileSupport,
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l.profileSupportTodo)),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton(
              onPressed: () async {
                await ref.read(authControllerProvider.notifier).signOut();
                if (context.mounted) context.go(AppRoutes.onboarding);
              },
              child: Text(l.profileSignOut),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => context.push(AppRoutes.profileAccountDelete),
              style: TextButton.styleFrom(foregroundColor: context.colors.error),
              child: Text(l.profileDeleteAccount),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _UserHeader extends StatelessWidget {
  const _UserHeader({required this.name, required this.phone, this.email});
  final String name;
  final String phone;
  final String? email;

  @override
  Widget build(BuildContext context) {
    final displayName = name.isEmpty ? '—' : name;
    final initials = name.isEmpty
        ? '?'
        : name
            .trim()
            .split(RegExp(r'\s+'))
            .where((s) => s.isNotEmpty)
            .map((s) => s[0].toUpperCase())
            .take(2)
            .join();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
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
                Text(displayName, style: AppTypography.titleLarge),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  phone,
                  style: AppTypography.bodySmall
                      .copyWith(color: context.colors.textSecondary),
                ),
                if (email != null && email!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    email!,
                    style: AppTypography.bodySmall
                        .copyWith(color: context.colors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          Semantics(
            image: true,
            label: context.l10n.profileAvatarSemantics(displayName),
            child: Container(
              width: AppSizes.avatar,
              height: AppSizes.avatar,
              decoration: BoxDecoration(
                // heroSurface stays dark in both modes — keeps the
                // dark-circle / yellow-initials brand look (brandBlack
                // would flip to cream in dark, hiding yellow initials).
                color: context.colors.heroSurface,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: ExcludeSemantics(
                child: Text(
                  initials,
                  style: AppTypography.titleMedium
                      .copyWith(color: context.colors.brandYellow),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleSummary extends StatelessWidget {
  const _VehicleSummary({required this.vehicle});
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final nextKm = vehicle.nextServiceMileageKm;
    final remaining = nextKm != null ? (nextKm - vehicle.mileageKm) : null;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
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
                Text('${vehicle.make} ${vehicle.model}',
                    style: AppTypography.titleSmall),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${vehicle.year} · ${vehicle.plate}',
                  style: AppTypography.bodySmall
                      .copyWith(color: context.colors.textSecondary),
                ),
              ],
            ),
          ),
          if (remaining != null && remaining > 0)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: context.colors.brandYellow,
                borderRadius: AppRadii.pillAll,
              ),
              child: Text(
                context.l10n.profileTOLeftPill(remaining),
                style: AppTypography.labelSmall
                    .copyWith(color: context.colors.onYellow),
              ),
            ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    this.trailing,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: trailing == null ? label : '$label, $trailing',
      child: Material(
        color: context.colors.surface,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: context.colors.border, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: AppIconSize.lg, color: context.colors.textPrimary),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(label, style: AppTypography.titleSmall),
                ),
                if (trailing != null) ...[
                  Text(
                    trailing!,
                    style: AppTypography.labelMedium
                        .copyWith(color: context.colors.textSecondary),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                ],
                Icon(Icons.chevron_right, color: context.colors.textDisabled),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
