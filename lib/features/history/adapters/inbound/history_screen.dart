import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/service_record_tile.dart';
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

/// Aggregated service history grouped by month. When [vehicleId] is null
/// (the default for the tab) the screen fetches every closed service across
/// every vehicle the customer owns. When non-null, the screen narrows to a
/// single vehicle — used by deeplinks from CarDetailScreen.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key, this.vehicleId});

  final String? vehicleId;

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  /// Records revealed per "page". Ten matches roughly one phone-screen worth
  /// of tiles — small enough that the user sees progress on each bump,
  /// big enough that we don't thrash setState during a fast fling.
  static const _pageSize = 10;

  /// Distance from the bottom (in logical pixels) at which we kick off the
  /// next batch. Bumping early avoids a visible gap while the next slice
  /// renders.
  static const _prefetchPx = 300.0;

  final _scrollController = ScrollController();
  int _visibleCount = _pageSize;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels < pos.maxScrollExtent - _prefetchPx) return;

    // Skip the bump if we've already revealed every record — otherwise
    // _visibleCount grows unbounded as the user keeps overscrolling at the
    // bottom, causing useless rebuilds.
    final id = widget.vehicleId;
    final total = id == null
        ? ref.read(aggregatedServiceHistoryProvider).value?.totalRecords
        : ref.read(serviceHistoryProvider(id)).value?.totalRecords;
    if (total != null && _visibleCount >= total) return;

    if (mounted) setState(() => _visibleCount += _pageSize);
  }

  Future<void> _refresh() async {
    if (mounted) setState(() => _visibleCount = _pageSize);
    final id = widget.vehicleId;
    if (id == null) {
      ref.invalidate(aggregatedServiceHistoryProvider);
      await ref.read(aggregatedServiceHistoryProvider.future);
    } else {
      ref.invalidate(serviceHistoryProvider(id));
      await ref.read(serviceHistoryProvider(id).future);
    }
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.vehicleId;
    final async = id == null
        ? ref.watch(aggregatedServiceHistoryProvider)
        : ref.watch(serviceHistoryProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.historyTitle, style: AppTypography.titleLarge),
      ),
      body: SafeArea(
        child: async.when(
          loading: () => const _HistorySkeleton(),
          error: (e, _) => ErrorState(onRetry: _refresh),
          data: (output) => RefreshIndicator(
            onRefresh: _refresh,
            child: output.months.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: EmptyState(
                          icon: Icons.history,
                          title: context.l10n.historyEmptyTitle,
                          subtitle: context.l10n.historyEmptySubtitle,
                        ),
                      ),
                    ],
                  )
                : _HistoryView(
                    output: output,
                    showVehicleLabel: id == null,
                    scrollController: _scrollController,
                    visibleCount: _visibleCount,
                  ),
          ),
        ),
      ),
    );
  }
}

/// Slice the month-grouped output to the first [n] records (records are
/// already newest-first inside and across months). Months that fall entirely
/// past the cut are dropped; the boundary month is truncated.
List<ServiceHistoryMonth> _firstNRecords(
  List<ServiceHistoryMonth> months,
  int n,
) {
  final out = <ServiceHistoryMonth>[];
  var remaining = n;
  for (final m in months) {
    if (remaining <= 0) break;
    if (m.records.length <= remaining) {
      out.add(m);
      remaining -= m.records.length;
    } else {
      out.add(
        ServiceHistoryMonth(
          year: m.year,
          month: m.month,
          records: m.records.take(remaining).toList(),
        ),
      );
      remaining = 0;
    }
  }
  return out;
}

class _HistoryView extends StatelessWidget {
  const _HistoryView({
    required this.output,
    required this.showVehicleLabel,
    required this.scrollController,
    required this.visibleCount,
  });

  final GetServiceHistoryOutput output;
  final bool showVehicleLabel;
  final ScrollController scrollController;
  final int visibleCount;

  @override
  Widget build(BuildContext context) {
    final completedTotal = output.totalRecords;
    final hasMore = visibleCount < completedTotal;
    final visibleMonths = _firstNRecords(output.months, visibleCount);

    return ListView(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      children: [
        // Completed count always reflects the full set — pagination is a
        // rendering concern, not a counting one.
        Text(
          context.l10n.historyCompletedCount(completedTotal),
          style: AppTypography.bodySmall
              .copyWith(color: context.colors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.lg),
        for (final month in visibleMonths) ...[
          _MonthHeader(year: month.year, month: month.month),
          const SizedBox(height: AppSpacing.sm),
          for (final record in month.records)
            ServiceRecordTile(
              title: record.title,
              dateLabel:
                  '${record.completedAt.day} ${_monthName(context.l10n, record.completedAt.month).toLowerCase()}',
              vehicleLabel: showVehicleLabel ? record.vehicle.label : null,
            ),
          const SizedBox(height: AppSpacing.lg),
        ],
        if (hasMore)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
      ],
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Loading record title', style: AppTypography.titleSmall),
              const SizedBox(height: AppSpacing.xxs),
              Text('Jan 1',
                  style: AppTypography.bodySmall
                      .copyWith(color: context.colors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}
