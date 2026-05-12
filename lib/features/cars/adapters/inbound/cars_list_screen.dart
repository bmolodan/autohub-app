import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../composition/cars_providers.dart';
import '../../domain/vehicle.dart';

class CarsListScreen extends ConsumerWidget {
  const CarsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(vehiclesControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Мої авто', style: AppTypography.titleLarge)),
      body: SafeArea(
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text('Не вдалося завантажити: $e',
                style: AppTypography.bodyMedium),
          ),
          data: (vehicles) => ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              for (final v in vehicles)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _VehicleCard(vehicle: v),
                ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: () => context.push(AppRoutes.carAdd),
                icon: const Icon(Icons.add),
                label: const Text('Додати авто'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({required this.vehicle});
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: AppRadii.lgAll,
      child: InkWell(
        borderRadius: AppRadii.lgAll,
        onTap: () => context.push('${AppRoutes.carDetail}/${vehicle.id}'),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: AppRadii.lgAll,
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.brandYellowSoft,
                  borderRadius: AppRadii.mdAll,
                ),
                child: const Icon(Icons.directions_car,
                    color: AppColors.brandBlack),
              ),
              const SizedBox(width: AppSpacing.md),
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
              const Icon(Icons.chevron_right, color: AppColors.textDisabled),
            ],
          ),
        ),
      ),
    );
  }
}
