import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../application/use_cases/get_service_history.dart';
import '../../composition/history_providers.dart';
import '../../domain/service_record.dart';

const _months = [
  '',
  'СІЧЕНЬ',
  'ЛЮТИЙ',
  'БЕРЕЗЕНЬ',
  'КВІТЕНЬ',
  'ТРАВЕНЬ',
  'ЧЕРВЕНЬ',
  'ЛИПЕНЬ',
  'СЕРПЕНЬ',
  'ВЕРЕСЕНЬ',
  'ЖОВТЕНЬ',
  'ЛИСТОПАД',
  'ГРУДЕНЬ',
];

/// Mockup 08 — service history grouped by month.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key, this.vehicleId = 'v-camry-1'});

  final String vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(serviceHistoryProvider(vehicleId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Історія', style: AppTypography.titleLarge),
      ),
      body: SafeArea(
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ErrorState(
            onRetry: () => ref.invalidate(serviceHistoryProvider(vehicleId)),
          ),
          data: (output) => output.months.isEmpty
              ? const EmptyState(
                  icon: Icons.history,
                  title: 'Історія порожня',
                  subtitle:
                      'Тут зʼявляться завершені роботи після першого візиту.',
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
          'Витрачено за весь час',
          style:
              AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
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
        decoration: const BoxDecoration(
          color: AppColors.brandYellow,
          borderRadius: AppRadii.pillAll,
        ),
        child: Text(label,
            style:
                AppTypography.labelMedium.copyWith(color: AppColors.onYellow)),
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
    final label = month >= 1 && month < _months.length ? _months[month] : '';
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
      child: Text(
        '$label $year',
        style: AppTypography.overline.copyWith(color: AppColors.textSecondary),
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
                Text(record.title, style: AppTypography.titleSmall),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${record.completedAt.day} ${_months[record.completedAt.month].toLowerCase()}',
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.textSecondary),
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
