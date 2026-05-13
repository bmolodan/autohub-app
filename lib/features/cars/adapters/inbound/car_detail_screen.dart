import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../composition/cars_providers.dart';
import '../../domain/vehicle.dart';

class CarDetailScreen extends ConsumerWidget {
  const CarDetailScreen({super.key, required this.vehicleId});
  final String vehicleId;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final confirmed = await showConfirmDialog(
      context,
      title: l.carDeleteDialogTitle,
      body: l.carDeleteDialogBody,
      confirmLabel: l.carDeleteDialogConfirm,
    );
    if (!confirmed || !context.mounted) return;
    try {
      await ref.read(vehiclesControllerProvider.notifier).remove(vehicleId);
    } on Object catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.errorGeneric)),
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
            onPressed: async.value == null
                ? null
                : () => context.push('${AppRoutes.carEdit}/$vehicleId'),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: context.colors.error),
            tooltip: l.carDetailDeleteSemantics,
            onPressed:
                async.value == null ? null : () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: SafeArea(
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Center(
            child: Text(l.errorGeneric, style: AppTypography.bodyMedium),
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
              width: AppSizes.iconBubble,
              height: AppSizes.iconBubble,
              decoration: BoxDecoration(
                color: context.colors.brandYellowSoft,
                borderRadius: AppRadii.lgAll,
              ),
              child: Icon(Icons.directions_car,
                  size: AppIconSize.hero, color: context.colors.brandBlack),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('${vehicle.make} ${vehicle.model}',
              style: AppTypography.headlineMedium, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xxs),
          Text('${vehicle.year} · ${vehicle.plate}',
              style: AppTypography.bodyMedium
                  .copyWith(color: context.colors.textSecondary),
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
      decoration: BoxDecoration(
        color: context.colors.brandYellow,
        borderRadius: AppRadii.lgAll,
      ),
      child: Row(
        children: [
          Icon(Icons.event, color: context.colors.onYellow),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l10n.carDetailNextService,
                    style: AppTypography.labelMedium
                        .copyWith(color: context.colors.onYellow)),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  remaining > 0
                      ? context.l10n.carDetailDueIn(remaining)
                      : context.l10n.carDetailOverdue,
                  style: AppTypography.titleMedium
                      .copyWith(color: context.colors.onYellow),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
