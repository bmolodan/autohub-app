import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../application/use_cases/get_service_history.dart';
import '../../composition/history_providers.dart';
import '../../domain/service_record.dart';

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
      _ => throw ArgumentError.value(month, 'month', 'must be 1..12'),
    };

/// Mockup 08 — service history grouped by month.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key, this.vehicleId = 'v-camry-1'});

  final String vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(serviceHistoryProvider(vehicleId));

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.historyTitle, style: AppTypography.titleLarge),
      ),
      body: SafeArea(
        child: async.when(
          loading: () => const _HistorySkeleton(),
          error: (e, _) => ErrorState(
            onRetry: () => ref.invalidate(serviceHistoryProvider(vehicleId)),
          ),
          data: (output) => output.months.isEmpty
              ? EmptyState(
                  icon: Icons.history,
                  title: context.l10n.historyEmptyTitle,
                  subtitle: context.l10n.historyEmptySubtitle,
                )
              : _HistoryView(output: output),
        ),
      ),
    );
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView({required this.output});
  final GetServiceHistoryOutput output;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      children: [
        const _VehicleChip(label: 'Toyota Camry'),
        const SizedBox(height: AppSpacing.md),
        Text(
          context.l10n.historyTotalLabel,
          style: AppTypography.bodySmall
              .copyWith(color: context.colors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text('${output.totalUah} ₴', style: AppTypography.headlineLarge),
        const SizedBox(height: AppSpacing.lg),
        for (final month in output.months) ...[
          _MonthHeader(year: month.year, month: month.month),
          const SizedBox(height: AppSpacing.sm),
          for (final record in month.records) _RecordTile(record: record),
          const SizedBox(height: AppSpacing.lg),
        ],
      ],
    );
  }
}

class _VehicleChip extends StatelessWidget {
  const _VehicleChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: context.colors.brandYellow,
          borderRadius: AppRadii.pillAll,
        ),
        child: Text(label,
            style: AppTypography.labelMedium
                .copyWith(color: context.colors.onYellow)),
      ),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({required this.year, required this.month});
  final int year;
  final int month;

  @override
  Widget build(BuildContext context) {
    final label = _monthName(context.l10n, month);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
      child: Text(
        '$label $year',
        style: AppTypography.overline
            .copyWith(color: context.colors.textSecondary),
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({required this.record});
  final ServiceRecord record;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
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
                Text(record.title, style: AppTypography.titleSmall),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${record.completedAt.day} ${_monthName(context.l10n, record.completedAt.month).toLowerCase()}',
                  style: AppTypography.bodySmall
                      .copyWith(color: context.colors.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            '${record.priceUah} ₴',
            style: AppTypography.labelLarge,
          ),
        ],
      ),
    );
  }
}

class _HistorySkeleton extends StatelessWidget {
  const _HistorySkeleton();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (_, __) => Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.md),
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
                    Text('Loading record title',
                        style: AppTypography.titleSmall),
                    const SizedBox(height: AppSpacing.xxs),
                    Text('Jan 1 · 0 km',
                        style: AppTypography.bodySmall
                            .copyWith(color: context.colors.textSecondary)),
                  ],
                ),
              ),
              Text('0 ₴', style: AppTypography.labelLarge),
            ],
          ),
        ),
      ),
    );
  }
}
