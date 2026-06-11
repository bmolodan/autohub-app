import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/util/date_format.dart';
import '../../../../core/widgets/brand_progress_bar.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../l10n/generated/app_localizations.dart';
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
          loading: () => const _LoadingSkeleton(),
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
    final l = context.l10n;
    final etaLabel = order.eta != null ? formatHm(order.eta!) : '—';
    // Background bleed from RoApp's per-status color (e.g. #099B49 for
    // "Платний"/in-work). Falls back to the design baseline.
    final heroBg = _parseHexColor(order.statusColor) ?? context.colors.heroSurface;
    final onHero = _onSurface(heroBg);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      children: [
        Hero(
          tag: 'order-hero-${order.id}',
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: heroBg,
                borderRadius: AppRadii.xlAll,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          orderStatusLabel(l, order.status).toUpperCase(),
                          style: AppTypography.overline
                              .copyWith(color: onHero.withValues(alpha: 0.85)),
                        ),
                      ),
                      _UrgencyChip(order: order),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(order.title,
                      style:
                          AppTypography.headlineSmall.copyWith(color: onHero)),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(order.vehicleSummary,
                      style: AppTypography.bodySmall.copyWith(
                          color: onHero.withValues(alpha: 0.7))),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: BrandProgressBar(value: order.progress ?? 0),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '~$etaLabel',
                        style: AppTypography.labelMedium
                            .copyWith(color: onHero),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _InfoRow(order: order),
        const SizedBox(height: AppSpacing.lg),
        Text(l.orderTimelineHeading,
            style: AppTypography.overline
                .copyWith(color: context.colors.textSecondary)),
        const SizedBox(height: AppSpacing.sm),
        _Timeline(entries: order.timeline),
        const SizedBox(height: AppSpacing.lg),
        _EstimateSection(order: order),
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
    final confirmed = await showConfirmDialog(
      context,
      title: l.orderCancelDialogTitle,
      body: l.orderCancelDialogBody,
      confirmLabel: l.orderCancelDialogConfirm,
    );
    if (!confirmed || !mounted) return;

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
        Hero(
          tag: 'order-hero-${order.id}',
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.colors.brandYellow,
                borderRadius: AppRadii.xlAll,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l.orderPendingHeroLabel,
                          style: AppTypography.overline
                              .copyWith(color: context.colors.onYellow),
                        ),
                      ),
                      _UrgencyChip(order: order),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(order.title,
                      style: AppTypography.headlineSmall
                          .copyWith(color: context.colors.onYellow)),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(order.vehicleSummary,
                      style: AppTypography.bodySmall
                          .copyWith(color: context.colors.onYellow)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        StatCard(label: l.orderScheduledTime, value: scheduledLabel),
        const SizedBox(height: AppSpacing.lg),
        _InfoRow(order: order),
        if (order.timeline.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(l.orderJournalHeading,
              style: AppTypography.overline
                  .copyWith(color: context.colors.textSecondary)),
          const SizedBox(height: AppSpacing.sm),
          _Timeline(entries: order.timeline),
        ],
        const SizedBox(height: AppSpacing.lg),
        _EstimateSection(order: order),
        const SizedBox(height: AppSpacing.lg),
        OutlinedButton(
          onPressed: _confirmCancel,
          style:
              OutlinedButton.styleFrom(foregroundColor: context.colors.error),
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
        Hero(
          tag: 'order-hero-${order.id}',
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.colors.errorSoft,
                borderRadius: AppRadii.xlAll,
                border: Border.all(color: context.colors.error, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.orderCanceledHeroLabel,
                    style: AppTypography.overline
                        .copyWith(color: context.colors.error),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(order.title, style: AppTypography.headlineSmall),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(order.vehicleSummary,
                      style: AppTypography.bodySmall
                          .copyWith(color: context.colors.textSecondary)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (order.timeline.isNotEmpty) ...[
          Text(context.l10n.orderJournalHeading,
              style: AppTypography.overline
                  .copyWith(color: context.colors.textSecondary)),
          const SizedBox(height: AppSpacing.sm),
          _Timeline(entries: order.timeline),
        ],
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.order});
  final ActiveOrder order;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final entries = <(String, String)>[
      if (order.orderType != null && order.orderType!.isNotEmpty)
        (l.orderInfoType, order.orderType!),
      if (order.resource != null && order.resource!.isNotEmpty)
        (l.orderInfoResource, order.resource!),
      if (order.dueDate != null)
        (l.orderInfoDueDate, formatDdMmHm(order.dueDate!)),
    ];
    if (entries.isEmpty) return const SizedBox.shrink();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < entries.length; i++) ...[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entries[i].$1,
                    style: AppTypography.overline
                        .copyWith(color: context.colors.textSecondary)),
                const SizedBox(height: AppSpacing.xxs),
                Text(entries[i].$2, style: AppTypography.bodyMedium),
              ],
            ),
          ),
          if (i < entries.length - 1) const SizedBox(width: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _UrgencyChip extends StatelessWidget {
  const _UrgencyChip({required this.order});
  final ActiveOrder order;

  @override
  Widget build(BuildContext context) {
    if (order.isOverdue) {
      return _Chip(
        icon: Icons.error_outline,
        label: context.l10n.orderOverdue,
        background: context.colors.error,
        foreground: Colors.white,
      );
    }
    if (order.isUrgent) {
      return _Chip(
        icon: Icons.priority_high,
        label: context.l10n.orderUrgent,
        background: context.colors.brandYellow,
        foreground: context.colors.onYellow,
      );
    }
    return const SizedBox.shrink();
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
  });
  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs, vertical: AppSpacing.xxs),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadii.smAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: AppSpacing.xxs),
          Text(label,
              style: AppTypography.labelSmall.copyWith(color: foreground)),
        ],
      ),
    );
  }
}

class _EstimateSection extends StatelessWidget {
  const _EstimateSection({required this.order});
  final ActiveOrder order;

  @override
  Widget build(BuildContext context) {
    if (order.items.isEmpty && order.totalUah == null) {
      return const SizedBox.shrink();
    }
    final l = context.l10n;
    final services =
        order.items.where((i) => i.kind == OrderItemKind.service).toList();
    final products =
        order.items.where((i) => i.kind == OrderItemKind.product).toList();
    final total = order.totalUah ?? 0;
    final paid = order.paidUah ?? 0;
    final discount = order.discountUah ?? 0;
    final balance = total - paid;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: context.colors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.orderEstimateHeading,
              style: AppTypography.overline
                  .copyWith(color: context.colors.textSecondary)),
          const SizedBox(height: AppSpacing.sm),
          if (services.isNotEmpty)
            _ItemGroup(label: l.orderEstimateServices, items: services),
          if (services.isNotEmpty && products.isNotEmpty)
            const SizedBox(height: AppSpacing.sm),
          if (products.isNotEmpty)
            _ItemGroup(label: l.orderEstimateProducts, items: products),
          if (order.items.isNotEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Divider(height: 1),
            ),
          if (order.totalUah != null) ...[
            _TotalRow(label: l.orderEstimateSubtotal, value: total),
            if (discount > 0)
              _TotalRow(
                  label: l.orderEstimateDiscount,
                  value: discount,
                  emphasize: false,
                  isNegative: true),
            if (paid > 0)
              _TotalRow(label: l.orderEstimatePaid, value: paid),
            const SizedBox(height: AppSpacing.xxs),
            _TotalRow(
                label: l.orderEstimateBalance, value: balance, emphasize: true),
          ],
        ],
      ),
    );
  }
}

class _ItemGroup extends StatelessWidget {
  const _ItemGroup({required this.label, required this.items});
  final String label;
  final List<OrderItem> items;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTypography.labelMedium
                .copyWith(color: context.colors.textSecondary)),
        const SizedBox(height: AppSpacing.xs),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: AppTypography.bodyMedium),
                      Text(
                        l.orderItemQtyPrice(item.quantity, item.priceUah),
                        style: AppTypography.bodySmall
                            .copyWith(color: context.colors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  l.orderMoney(item.sumUah),
                  style: AppTypography.bodyMedium
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    this.emphasize = false,
    this.isNegative = false,
  });
  final String label;
  final int value;
  final bool emphasize;
  final bool isNegative;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final amount = isNegative ? '−${l.orderMoney(value)}' : l.orderMoney(value);
    final style = emphasize
        ? AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700)
        : AppTypography.bodyMedium;
    final labelStyle = emphasize
        ? style
        : AppTypography.bodyMedium.copyWith(color: context.colors.textSecondary);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        children: [
          Expanded(child: Text(label, style: labelStyle)),
          Text(amount, style: style),
        ],
      ),
    );
  }
}

Color? _parseHexColor(String? hex) {
  if (hex == null) return null;
  var s = hex.trim();
  if (s.startsWith('#')) s = s.substring(1);
  if (s.length == 6) s = 'FF$s';
  if (s.length != 8) return null;
  final v = int.tryParse(s, radix: 16);
  if (v == null) return null;
  return Color(v);
}

Color _onSurface(Color bg) {
  return bg.computeLuminance() > 0.55 ? Colors.black87 : Colors.white;
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
          color: context.colors.surface,
          borderRadius: AppRadii.lgAll,
          border: Border.all(color: context.colors.border, width: 0.5),
        ),
        child: Text(
          context.l10n.orderTimelineEmpty,
          style: AppTypography.bodySmall
              .copyWith(color: context.colors.textSecondary),
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
              rail: context.colors.borderStrong,
              currentDot: context.colors.brandYellow,
              dot: context.colors.brandBlack,
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
                      .copyWith(color: context.colors.textSecondary),
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
    required this.rail,
    required this.currentDot,
    required this.dot,
  });

  final bool isFirst;
  final bool isLast;
  final bool isCurrent;
  final Color rail;
  final Color currentDot;
  final Color dot;

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    const dotRadius = 6.0;
    const dotCenterY = 16.0;
    final line = Paint()
      ..color = rail
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
      Paint()..color = isCurrent ? currentDot : dot,
    );
    canvas.drawCircle(
      Offset(centerX, dotCenterY),
      dotRadius,
      Paint()
        ..color = dot
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_TimelineRailPainter old) =>
      old.isFirst != isFirst ||
      old.isLast != isLast ||
      old.isCurrent != isCurrent ||
      old.rail != rail ||
      old.currentDot != currentDot ||
      old.dot != dot;
}

/// Generic loading skeleton used while the order is loading — the status is
/// not known yet, so the shape is intentionally neutral (surfaceVariant
/// hero + a stat-card row + a few timeline rows) and works for both the
/// in-progress and pending body layouts.
class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: context.colors.surfaceVariant,
              borderRadius: AppRadii.xlAll,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('LOADING STATUS',
                    style: AppTypography.overline
                        .copyWith(color: context.colors.textSecondary)),
                const SizedBox(height: AppSpacing.xxs),
                Text('Loading service title',
                    style: AppTypography.headlineSmall),
                const SizedBox(height: AppSpacing.xxs),
                Text('Loading vehicle info',
                    style: AppTypography.bodySmall
                        .copyWith(color: context.colors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Stat-card row — present on pending body (Scheduled time) and
          // in-progress body (Estimate). Same shape on both.
          const StatCard(label: 'Loading label', value: 'Loading value'),
          const SizedBox(height: AppSpacing.lg),
          Text('JOURNAL',
              style: AppTypography.overline
                  .copyWith(color: context.colors.textSecondary)),
          const SizedBox(height: AppSpacing.sm),
          for (var i = 0; i < 3; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Text('Stage placeholder', style: AppTypography.titleSmall),
            ),
        ],
      ),
    );
  }
}

// Keep the import non-unused: AppLocalizations is referenced through
// `context.l10n` (ext getter) — the explicit import is for callers of
// helpers below if/when they need typed `l` outside `context.l10n`.
// ignore: unused_element
typedef _UnusedL = AppLocalizations;
