import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/util/date_format.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../composition/orders_providers.dart';
import '../../domain/active_order.dart';

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
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ErrorState(
            onRetry: () => ref.invalidate(orderByIdProvider(orderId)),
          ),
          data: (order) {
            if (order == null) {
              return const EmptyState(
                icon: Icons.search_off,
                title: 'Замовлення не знайдено',
                subtitle: 'Можливо, його було видалено.',
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
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: const BoxDecoration(
            color: AppColors.brandBlack,
            borderRadius: AppRadii.xlAll,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.statusLabel.toUpperCase(),
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
                        valueColor:
                            const AlwaysStoppedAnimation(AppColors.brandYellow),
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
        const SizedBox(height: AppSpacing.lg),
        Text('ХІД РОБОТИ',
            style: AppTypography.overline
                .copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: AppSpacing.sm),
        _Timeline(entries: order.timeline),
        const SizedBox(height: AppSpacing.lg),
        if (order.totalUah != null)
          StatCard(
            label: 'Орієнтовно',
            value: '${order.totalUah} ₴',
          ),
        const SizedBox(height: AppSpacing.lg),
        OutlinedButton.icon(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Виклик майстра: TODO')),
          ),
          icon: const Icon(Icons.call_outlined),
          label: const Text('Зателефонувати майстру'),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

class _PendingBody extends StatelessWidget {
  const _PendingBody({required this.order});
  final ActiveOrder order;

  @override
  Widget build(BuildContext context) {
    final scheduledLabel = order.scheduledFor != null
        ? formatDdMmHm(order.scheduledFor!)
        : 'визначимо невдовзі';

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
                'ОЧІКУЄ ПІДТВЕРДЖЕННЯ',
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
        StatCard(label: 'Запланований час', value: scheduledLabel),
        if (order.totalUah != null) ...[
          const SizedBox(height: AppSpacing.sm),
          StatCard(label: 'Орієнтовно', value: 'від ${order.totalUah} ₴'),
        ],
        const SizedBox(height: AppSpacing.lg),
        if (order.timeline.isNotEmpty) ...[
          Text('ЖУРНАЛ',
              style: AppTypography.overline
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.sm),
          _Timeline(entries: order.timeline),
          const SizedBox(height: AppSpacing.lg),
        ],
        OutlinedButton(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Скасування запису: TODO')),
          ),
          style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
          child: const Text('Скасувати запис'),
        ),
        const SizedBox(height: AppSpacing.lg),
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
          'Поки що жодних подій',
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
                Text(entry.label, style: AppTypography.titleSmall),
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
