import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../composition/cars_providers.dart';
import '../../domain/vehicle.dart';

class CarDetailScreen extends ConsumerWidget {
  const CarDetailScreen({super.key, required this.vehicleId});
  final String vehicleId;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.carDeleteDialogTitle),
        content: Text(l.carDeleteDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.commonNo),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l.carDeleteDialogConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(vehiclesControllerProvider.notifier).remove(vehicleId);
    } on Object catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
      return;
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.carDeleteSuccessSnack)),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(vehicleByIdProvider(vehicleId));
    final l = context.l10n;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: l.carDetailEditSemantics,
            onPressed: async.valueOrNull == null
                ? null
                : () => context.push('${AppRoutes.carEdit}/$vehicleId'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            tooltip: l.carDetailDeleteSemantics,
            onPressed: async.valueOrNull == null
                ? null
                : () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: SafeArea(
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text('$e', style: AppTypography.bodyMedium),
          ),
          data: (v) {
            if (v == null) {
              return Center(
                child: Text(context.l10n.carDetailNotFound,
                    style: AppTypography.bodyMedium),
              );
            }
            return _Detail(vehicle: v);
          },
        ),
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.vehicle});
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: AppColors.brandYellowSoft,
                borderRadius: AppRadii.lgAll,
              ),
              child: const Icon(Icons.directions_car,
                  size: 40, color: AppColors.brandBlack),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('${vehicle.make} ${vehicle.model}',
              style: AppTypography.headlineMedium, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xxs),
          Text('${vehicle.year} · ${vehicle.plate}',
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xl),
          if (vehicle.nextServiceMileageKm != null)
            _NextServiceBanner(
              currentKm: vehicle.mileageKm,
              nextKm: vehicle.nextServiceMileageKm!,
            ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  axis: Axis.vertical,
                  label: context.l10n.carDetailMileage,
                  value: context.l10n.carDetailMileageValue(vehicle.mileageKm),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: StatCard(
                  axis: Axis.vertical,
                  label: context.l10n.carDetailVin,
                  value: vehicle.vin ?? '—',
                ),
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.l10n.carDetailBookTodo)),
            ),
            icon: const Icon(Icons.add),
            label: Text(context.l10n.carDetailBook),
          ),
        ],
      ),
    );
  }
}

class _NextServiceBanner extends StatelessWidget {
  const _NextServiceBanner({required this.currentKm, required this.nextKm});
  final int currentKm;
  final int nextKm;

  @override
  Widget build(BuildContext context) {
    final remaining = nextKm - currentKm;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.brandYellow,
        borderRadius: AppRadii.lgAll,
      ),
      child: Row(
        children: [
          const Icon(Icons.event, color: AppColors.brandBlack),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l10n.carDetailNextService,
                    style: AppTypography.labelMedium
                        .copyWith(color: AppColors.brandBlack)),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  remaining > 0
                      ? context.l10n.carDetailDueIn(remaining)
                      : context.l10n.carDetailOverdue,
                  style: AppTypography.titleMedium
                      .copyWith(color: AppColors.brandBlack),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
