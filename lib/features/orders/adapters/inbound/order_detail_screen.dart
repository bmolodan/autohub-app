import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/util/date_format.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../composition/orders_providers.dart';
import '../../domain/active_order.dart';
import '../../presentation/order_l10n.dart';

class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(orderByIdProvider(orderId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: async.when(
          loading: () => Skeletonizer(
            enabled: true,
            child: ListView(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: const BoxDecoration(
                    color: AppColors.brandBlack,
                    borderRadius: AppRadii.xlAll,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('LOADING STATUS',
                          style: AppTypography.overline
                              .copyWith(color: AppColors.brandYellow)),
                      const SizedBox(height: AppSpacing.xxs),
                      Text('Loading service title',
                          style: AppTypography.headlineSmall
                              .copyWith(color: AppColors.onBlack)),
                      const SizedBox(height: AppSpacing.xxs),
                      Text('Loading vehicle info',
                          style: AppTypography.bodySmall
                              .copyWith(color: AppColors.textDisabled)),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                for (var i = 0; i < 3; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Text('Stage placeholder',
                        style: AppTypography.titleSmall),
                  ),
              ],
            ),
          ),
          error: (e, _) => ErrorState(
            onRetry: () => ref.invalidate(orderByIdProvider(orderId)),
          ),
          data: (order) {
            if (order == null) {
              return EmptyState(
                icon: Icons.search_off,
                title: context.l10n.orderNotFoundTitle,
                subtitle: context.l10n.orderNotFoundSubtitle,
              );
            }
            return _Detail(order: order);
          },
        ),
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.order});
  final ActiveOrder order;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: switch (order.status) {
        ActiveOrderStatus.inProgress => _InProgressBody(order: order),
        ActiveOrderStatus.pendingConfirmation => _PendingBody(order: order),
        ActiveOrderStatus.canceled => _CanceledBody(order: order),
      },
    );
  }
}

class _InProgressBody extends StatelessWidget {
  const _InProgressBody({required this.order});
  final ActiveOrder order;

  @override
  Widget build(BuildContext context) {
    final etaLabel = order.eta != null ? formatHm(order.eta!) : '—';

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      children: [
        Hero(
          tag: 'order-hero-${order.id}',
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: const BoxDecoration(
                color: AppColors.brandBlack,
                borderRadius: AppRadii.xlAll,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    orderStatusLabel(context.l10n, order.status).toUpperCase(),
                    style: AppTypography.overline
                        .copyWith(color: AppColors.brandYellow),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(order.title,
                      style: AppTypography.headlineSmall
                          .copyWith(color: AppColors.onBlack)),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(order.vehicleSummary,
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.textDisabled)),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: AppRadii.xsAll,
                          child: LinearProgressIndicator(
                            value: order.progress ?? 0,
                            minHeight: 6,
                            backgroundColor:
                                AppColors.borderStrong.withValues(alpha: 0.4),
                            valueColor: const AlwaysStoppedAnimation(
                                AppColors.brandYellow),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '~$etaLabel',
                        style: AppTypography.labelMedium
                            .copyWith(color: AppColors.brandYellow),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(context.l10n.orderTimelineHeading,
            style: AppTypography.overline
                .copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: AppSpacing.sm),
        _Timeline(entries: order.timeline),
        const SizedBox(height: AppSpacing.lg),
        if (order.totalUah != null)
          StatCard(
            label: context.l10n.orderEstimate,
            value: context.l10n.orderEstimateValue(order.totalUah!),
          ),
        const SizedBox(height: AppSpacing.lg),
        OutlinedButton.icon(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.orderCallMasterTodo)),
          ),
          icon: const Icon(Icons.call_outlined),
          label: Text(context.l10n.orderCallMaster),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

class _PendingBody extends ConsumerStatefulWidget {
  const _PendingBody({required this.order});
  final ActiveOrder order;

  @override
  ConsumerState<_PendingBody> createState() => _PendingBodyState();
}

class _PendingBodyState extends ConsumerState<_PendingBody> {
  Future<void> _confirmCancel() async {
    final l = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.orderCancelDialogTitle),
        content: Text(l.orderCancelDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.commonNo),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l.orderCancelDialogConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await ref.read(ordersControllerProvider.notifier).cancel(widget.order.id);
    } on Object catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.orderCancelError(e.toString()))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final l = context.l10n;
    final scheduledLabel = order.scheduledFor != null
        ? formatDdMmHm(order.scheduledFor!)
        : l.orderScheduledTbd;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: const BoxDecoration(
            color: AppColors.brandYellow,
            borderRadius: AppRadii.xlAll,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.orderPendingHeroLabel,
                style: AppTypography.overline
                    .copyWith(color: AppColors.brandBlack),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(order.title,
                  style: AppTypography.headlineSmall
                      .copyWith(color: AppColors.brandBlack)),
              const SizedBox(height: AppSpacing.xxs),
              Text(order.vehicleSummary,
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.brandBlack)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        StatCard(label: l.orderScheduledTime, value: scheduledLabel),
        if (order.totalUah != null) ...[
          const SizedBox(height: AppSpacing.sm),
          StatCard(
            label: l.orderEstimate,
            value: l.orderEstimateValueFrom(order.totalUah!),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        if (order.timeline.isNotEmpty) ...[
          Text(l.orderJournalHeading,
              style: AppTypography.overline
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.sm),
          _Timeline(entries: order.timeline),
          const SizedBox(height: AppSpacing.lg),
        ],
        OutlinedButton(
          onPressed: _confirmCancel,
          style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
          child: Text(l.orderCancelLabel),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

class _CanceledBody extends StatelessWidget {
  const _CanceledBody({required this.order});
  final ActiveOrder order;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.errorSoft,
            borderRadius: AppRadii.xlAll,
            border: Border.all(color: AppColors.error, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.orderCanceledHeroLabel,
                style: AppTypography.overline.copyWith(color: AppColors.error),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(order.title, style: AppTypography.headlineSmall),
              const SizedBox(height: AppSpacing.xxs),
              Text(order.vehicleSummary,
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (order.timeline.isNotEmpty) ...[
          Text(context.l10n.orderJournalHeading,
              style: AppTypography.overline
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.sm),
          _Timeline(entries: order.timeline),
        ],
      ],
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.entries});
  final List<OrderTimelineEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.lgAll,
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Text(
          context.l10n.orderTimelineEmpty,
          style:
              AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
      );
    }
    return Column(
      children: [
        for (var i = 0; i < entries.length; i++)
          _TimelineRow(
            entry: entries[i],
            isFirst: i == 0,
            isLast: i == entries.length - 1,
            isCurrent: i == entries.length - 1,
          ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.entry,
    required this.isFirst,
    required this.isLast,
    required this.isCurrent,
  });

  final OrderTimelineEntry entry;
  final bool isFirst;
  final bool isLast;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final stamp = formatDdMmHm(entry.at);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 28,
          height: _railHeight,
          child: CustomPaint(
            painter: _TimelineRailPainter(
              isFirst: isFirst,
              isLast: isLast,
              isCurrent: isCurrent,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(orderStageLabel(context.l10n, entry.stage),
                    style: AppTypography.titleSmall),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  stamp,
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static const double _railHeight = 56;
}

class _TimelineRailPainter extends CustomPainter {
  const _TimelineRailPainter({
    required this.isFirst,
    required this.isLast,
    required this.isCurrent,
  });

  final bool isFirst;
  final bool isLast;
  final bool isCurrent;

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    const dotRadius = 6.0;
    const dotCenterY = 16.0;
    final line = Paint()
      ..color = AppColors.borderStrong
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;

    if (!isFirst) {
      canvas.drawRect(
        Rect.fromLTWH(centerX - 1, 0, 2, dotCenterY - dotRadius),
        line,
      );
    }
    if (!isLast) {
      canvas.drawRect(
        Rect.fromLTWH(
          centerX - 1,
          dotCenterY + dotRadius,
          2,
          size.height - (dotCenterY + dotRadius),
        ),
        line,
      );
    }

    canvas.drawCircle(
      Offset(centerX, dotCenterY),
      dotRadius,
      Paint()..color = isCurrent ? AppColors.brandYellow : AppColors.brandBlack,
    );
    canvas.drawCircle(
      Offset(centerX, dotCenterY),
      dotRadius,
      Paint()
        ..color = AppColors.brandBlack
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_TimelineRailPainter old) =>
      old.isFirst != isFirst ||
      old.isLast != isLast ||
      old.isCurrent != isCurrent;
}
