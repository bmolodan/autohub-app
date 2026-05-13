import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../composition/cars_providers.dart';
import '../../domain/vehicle.dart';

class CarsListScreen extends ConsumerWidget {
  const CarsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(vehiclesControllerProvider);

    return Scaffold(
      appBar: AppBar(
          title: Text(context.l10n.carsListTitle,
              style: AppTypography.titleLarge)),
      body: SafeArea(
        child: async.when(
          loading: () => Skeletonizer(
            enabled: true,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: const [
                Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _VehicleCard(vehicle: _skeletonVehicle),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _VehicleCard(vehicle: _skeletonVehicle),
                ),
              ],
            ),
          ),
          error: (e, _) => Center(
            child: Text(context.l10n.carsLoadFailed(e.toString()),
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
                label: Text(context.l10n.carsAddCta),
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
                width: AppSizes.avatar,
                height: AppSizes.avatar,
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

const _skeletonVehicle = Vehicle(
  id: 'skeleton',
  make: 'Make',
  model: 'Model',
  year: 2020,
  plate: 'AA 0000 BB',
  vin: null,
  mileageKm: 50000,
  nextServiceMileageKm: null,
);
