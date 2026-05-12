import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../auth/composition/auth_providers.dart';
import '../../cars/composition/cars_providers.dart';
import '../../cars/domain/vehicle.dart';

/// Mockup 09 — user profile.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(vehiclesControllerProvider);
    final session = ref.watch(authControllerProvider).asData?.value;
    final phone = session?.phone ?? '+380 67 123 45 67';

    return Scaffold(
      appBar: AppBar(title: Text('Профіль', style: AppTypography.titleLarge)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          children: [
            _UserHeader(name: 'Богдан М.', phone: phone),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'МОЇ АВТО',
              style: AppTypography.overline
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.sm),
            async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('$e', style: AppTypography.bodyMedium),
              data: (cars) => Column(
                children: [
                  for (final car in cars) _VehicleSummary(vehicle: car),
                  const SizedBox(height: AppSpacing.xxs),
                  OutlinedButton.icon(
                    onPressed: () => context.push(AppRoutes.carAdd),
                    icon: const Icon(Icons.add),
                    label: const Text('Додати авто'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _SettingsRow(
              icon: Icons.notifications_outlined,
              label: 'Сповіщення',
              onTap: () => context.push(AppRoutes.profileNotifications),
            ),
            _SettingsRow(
              icon: Icons.language_outlined,
              label: 'Мова',
              trailing: 'UA',
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Перемикач мови: TODO')),
              ),
            ),
            _SettingsRow(
              icon: Icons.support_agent_outlined,
              label: 'Підтримка',
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Контакти підтримки: TODO')),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton(
              onPressed: () async {
                await ref.read(authControllerProvider.notifier).signOut();
                if (context.mounted) context.go(AppRoutes.onboarding);
              },
              child: const Text('Вийти'),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => context.push(AppRoutes.profileAccountDelete),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Видалити акаунт'),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _UserHeader extends StatelessWidget {
  const _UserHeader({required this.name, required this.phone});
  final String name;
  final String phone;

  @override
  Widget build(BuildContext context) {
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .map((s) => s[0].toUpperCase())
        .take(2)
        .join();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTypography.titleLarge),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  phone,
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Semantics(
            image: true,
            label: 'Аватар $name',
            child: Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AppColors.brandBlack,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: ExcludeSemantics(
                child: Text(
                  initials,
                  style: AppTypography.titleMedium
                      .copyWith(color: AppColors.brandYellow),
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
        color: AppColors.surface,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.border, width: 0.5),
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
                      .copyWith(color: AppColors.textSecondary),
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
              decoration: const BoxDecoration(
                color: AppColors.brandYellow,
                borderRadius: AppRadii.pillAll,
              ),
              child: Text(
                'ТО за $remaining км',
                style: AppTypography.labelSmall
                    .copyWith(color: AppColors.onYellow),
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
    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.border, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: AppColors.textPrimary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(label, style: AppTypography.titleSmall),
              ),
              if (trailing != null) ...[
                Text(
                  trailing!,
                  style: AppTypography.labelMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
              const Icon(Icons.chevron_right, color: AppColors.textDisabled),
            ],
          ),
        ),
      ),
    );
  }
}
