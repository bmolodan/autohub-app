import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/config/app_environment.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../composition/cars_providers.dart';
import '../../domain/vehicle.dart';

class CarsListScreen extends ConsumerWidget {
  const CarsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(vehiclesControllerProvider);
    // In remote mode vehicles are synced from RoApp orders — manual add is
    // not supported until the booking creation flow is implemented.
    final canAdd = ref.watch(appEnvironmentProvider) == AppEnvironment.local;

    Future<void> refresh() async {
      ref.invalidate(vehiclesControllerProvider);
      await ref.read(vehiclesControllerProvider.future);
    }

    return Scaffold(
      appBar: AppBar(
          title: Text(context.l10n.carsListTitle,
              style: AppTypography.titleLarge)),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: refresh,
          child: async.when(
            loading: () => Skeletonizer(
              enabled: true,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
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
            error: (e, _) => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Center(
                    child: Text(context.l10n.carsLoadFailed(e.toString()),
                        style: AppTypography.bodyMedium),
                  ),
                ),
              ],
            ),
            data: (vehicles) => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                for (final v in vehicles)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _VehicleCard(vehicle: v),
                  ),
                if (canAdd) ...[
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: () => context.push(AppRoutes.carAdd),
                    icon: const Icon(Icons.add),
                    label: Text(context.l10n.carsAddCta),
                  ),
                ],
              ],
            ),
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
      color: context.colors.surface,
      borderRadius: AppRadii.lgAll,
      child: InkWell(
        borderRadius: AppRadii.lgAll,
        onTap: () => context.push('${AppRoutes.carDetail}/${vehicle.id}'),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: AppRadii.lgAll,
            border: Border.all(color: context.colors.border, width: 0.5),
          ),
          child: Row(
            children: [
              Container(
                width: AppSizes.avatar,
                height: AppSizes.avatar,
                decoration: BoxDecoration(
                  color: context.colors.brandYellowSoft,
                  borderRadius: AppRadii.mdAll,
                ),
                child: Icon(Icons.directions_car,
                    color: context.colors.brandBlack),
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
                          .copyWith(color: context.colors.textSecondary),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: context.colors.textDisabled),
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
