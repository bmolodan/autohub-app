import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_environment.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/service_record_tile.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../history/composition/history_providers.dart';
import '../../../history/domain/service_record.dart';
import '../../composition/cars_providers.dart';
import '../../domain/vehicle.dart';

String _shortMonth(AppLocalizations l, int m) => _monthName(l, m).toLowerCase();

String _monthName(AppLocalizations l, int month) => switch (month) {
      1 => l.monthJanuary,
      2 => l.monthFebruary,
      3 => l.monthMarch,
      4 => l.monthApril,
      5 => l.monthMay,
      6 => l.monthJune,
      7 => l.monthJuly,
      8 => l.monthAugust,
      9 => l.monthSeptember,
      10 => l.monthOctober,
      11 => l.monthNovember,
      12 => l.monthDecember,
      _ => '',
    };

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
    // Edit/delete not available in remote mode — vehicles are read-only,
    // synced from RoApp orders.
    final canEdit = ref.watch(appEnvironmentProvider) == AppEnvironment.local;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (canEdit) ...[
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
              onPressed: async.value == null
                  ? null
                  : () => _confirmDelete(context, ref),
            ),
          ],
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

class _Detail extends ConsumerWidget {
  const _Detail({required this.vehicle});
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final history = ref.watch(serviceHistoryProvider(vehicle.id)).value;
    final recent = <ServiceRecord>[];
    if (history != null) {
      for (final month in history.months) {
        for (final r in month.records) {
          if (recent.length >= 3) break;
          recent.add(r);
        }
        if (recent.length >= 3) break;
      }
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
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
        Text(
          [vehicle.make, vehicle.model, vehicle.modification]
              .where((s) => s.isNotEmpty)
              .join(' '),
          style: AppTypography.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          [
            vehicle.year.toString(),
            if (vehicle.plate.isNotEmpty) vehicle.plate,
          ].join(' · '),
          style: AppTypography.bodyMedium
              .copyWith(color: context.colors.textSecondary),
          textAlign: TextAlign.center,
        ),
        if (vehicle.vin != null && vehicle.vin!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text('${l.carDetailVin}: ${vehicle.vin}',
              style: AppTypography.bodySmall
                  .copyWith(color: context.colors.textTertiary),
              textAlign: TextAlign.center),
        ],
        if (vehicle.color.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(vehicle.color,
              style: AppTypography.bodySmall
                  .copyWith(color: context.colors.textTertiary),
              textAlign: TextAlign.center),
        ],
        const SizedBox(height: AppSpacing.xl),
        if (vehicle.nextServiceMileageKm != null)
          _NextServiceBanner(
            currentKm: vehicle.mileageKm,
            nextKm: vehicle.nextServiceMileageKm!,
          ),
        // Mileage card only when we actually have a non-zero value — RoApp
        // doesn't carry mileage today, so in remote mode this stays hidden.
        if (vehicle.mileageKm > 0) ...[
          const SizedBox(height: AppSpacing.lg),
          StatCard(
            axis: Axis.vertical,
            label: l.carDetailMileage,
            value: l.carDetailMileageValue(vehicle.mileageKm),
          ),
        ],
        if (recent.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(
            l.carDetailRecentJobs,
            style: AppTypography.overline
                .copyWith(color: context.colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final r in recent)
            ServiceRecordTile(
              title: r.title,
              dateLabel:
                  '${r.completedAt.day} ${_shortMonth(l, r.completedAt.month)}',
            ),
        ],
        const SizedBox(height: AppSpacing.lg),
        FilledButton.icon(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l.carDetailBookTodo)),
          ),
          icon: const Icon(Icons.add),
          label: Text(l.carDetailBook),
        ),
      ],
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
