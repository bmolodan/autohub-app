import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/util/date_format.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../l10n/l10n_extension.dart';
import '../../orders/composition/orders_providers.dart';
import '../../orders/domain/active_order.dart';
import '../../cars/composition/cars_providers.dart';
import '../../orders/presentation/order_l10n.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  /// Where the booking entry button goes. If we've resolved that the
  /// user has zero vehicles, detour through Add Car with a `?next=` back
  /// to booking step 1 so they don't hit the snackbar fallback on the
  /// problem-form step. While vehicles are still loading, default to the
  /// normal booking entry — the booking flow handles the empty edge
  /// case itself if it slips through.
  String _bookingTarget(List<Object>? vehicles) {
    if (vehicles != null && vehicles.isEmpty) {
      return '${AppRoutes.carAdd}'
          '?${QueryParams.nextRoute}='
          '${Uri.encodeQueryComponent(AppRoutes.bookingService)}';
    }
    return AppRoutes.bookingService;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(ordersControllerProvider);
    final vehicles = ref.watch(vehiclesControllerProvider).value;
    final bookingTarget = _bookingTarget(vehicles);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(context.l10n.appName,
                      style: AppTypography.titleMedium),
                ),
                IconButton(
                  onPressed: () {},
                  tooltip: context.l10n.homeNotificationsHint,
                  icon: Icon(
                    Icons.notifications_none_outlined,
                    semanticLabel: context.l10n.homeNotificationsHint,
                  ),
                ),
                IconButton(
                  onPressed: () => context.push(AppRoutes.showcase),
                  tooltip: context.l10n.homeDesignTokensHint,
                  icon: Icon(
                    Icons.palette_outlined,
                    semanticLabel: context.l10n.homeDesignTokensSemantics,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              context.l10n.homeGreetingPrefix,
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
            Text(context.l10n.homeUserName,
                style: AppTypography.headlineMedium),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: async.when(
                loading: () => HeroMode(
                  enabled: false,
                  child: Skeletonizer(
                    enabled: true,
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: 2,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (_, __) => _OrderCard(order: _skeletonOrder),
                    ),
                  ),
                ),
                error: (e, _) => ErrorState(
                  onRetry: () => ref.invalidate(ordersControllerProvider),
                ),
                data: (orders) =>
                    _buildOrderList(context, orders, bookingTarget),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ElevatedButton(
              onPressed: () => context.push(bookingTarget),
              child: Text(context.l10n.homeBookingCta),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(
      BuildContext context, List<ActiveOrder> orders, String bookingTarget) {
    final active = <ActiveOrder>[];
    final canceled = <ActiveOrder>[];
    for (final o in orders) {
      (o.status == ActiveOrderStatus.canceled ? canceled : active).add(o);
    }
    // EmptyState fires only when both buckets are empty. A canceled-only
    // case still shows the archive (canceled orders are real history)
    // and relies on the persistent "+ Записатись" CTA below the list.
    if (active.isEmpty && canceled.isEmpty) {
      return EmptyState(
        icon: Icons.car_repair_outlined,
        title: context.l10n.homeEmptyTitle,
        subtitle: context.l10n.homeEmptySubtitle,
        ctaLabel: context.l10n.homeEmptyCta,
        onCta: () => context.push(bookingTarget),
      );
    }
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        for (int i = 0; i < active.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.sm),
          _OrderCard(order: active[i]),
        ],
        if (canceled.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          _CanceledArchive(orders: canceled),
        ],
      ],
    );
  }
}

class _CanceledArchive extends StatelessWidget {
  const _CanceledArchive({required this.orders});
  final List<ActiveOrder> orders;

  static const _maxVisible = 5;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    // Newest-first; cap to _maxVisible so a long-tenured account doesn't
    // bloat Home into an infinite scroll of grey cards.
    final sorted = [...orders]..sort((a, b) {
        final aAt = a.timeline.isNotEmpty
            ? a.timeline.last.at
            : (a.scheduledFor ?? a.eta);
        final bAt = b.timeline.isNotEmpty
            ? b.timeline.last.at
            : (b.scheduledFor ?? b.eta);
        if (aAt == null && bAt == null) return 0;
        if (aAt == null) return 1;
        if (bAt == null) return -1;
        return bAt.compareTo(aAt);
      });
    final visible = sorted.take(_maxVisible).toList(growable: false);
    return Material(
      type: MaterialType.transparency,
      child: Theme(
        // ExpansionTile's default theming pulls in divider lines we don't
        // want; strip them so the archive blends with the home palette.
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(top: AppSpacing.sm),
          // Default is center-align — without stretch, the canceled cards
          // inside size to content and visually misalign with the active
          // cards above.
          expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
          title: Text(l.homeArchiveTitle, style: AppTypography.titleSmall),
          subtitle: Text(
            l.homeArchiveCount(orders.length),
            style: AppTypography.bodySmall
                .copyWith(color: AppColors.textSecondary),
          ),
          children: [
            for (int i = 0; i < visible.length; i++) ...[
              if (i > 0) const SizedBox(height: AppSpacing.sm),
              _OrderCard(order: visible[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});
  final ActiveOrder order;

  @override
  Widget build(BuildContext context) {
    final statusLabel = orderStatusLabel(context.l10n, order.status);
    final child = switch (order.status) {
      ActiveOrderStatus.inProgress => _InProgressCard(order: order),
      ActiveOrderStatus.pendingConfirmation =>
        _PendingConfirmationCard(order: order),
      ActiveOrderStatus.canceled => _CanceledCard(order: order),
    };
    return Semantics(
      button: true,
      label: '$statusLabel. ${order.title}. ${order.vehicleSummary}',
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadii.xlAll,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('${AppRoutes.orderDetail}/${order.id}'),
          child: child,
        ),
      ),
    );
  }
}

class _InProgressCard extends StatelessWidget {
  const _InProgressCard({required this.order});
  final ActiveOrder order;

  @override
  Widget build(BuildContext context) {
    final etaLabel = order.eta != null ? '~${formatHm(order.eta!)}' : '';

    return Hero(
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
                style: AppTypography.overline.copyWith(
                  color: AppColors.brandYellow,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                order.title,
                style:
                    AppTypography.titleLarge.copyWith(color: AppColors.onBlack),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                order.vehicleSummary,
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.textDisabled),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: AppRadii.xsAll,
                      child: LinearProgressIndicator(
                        value: order.progress ?? 0,
                        minHeight: 4,
                        backgroundColor:
                            AppColors.borderStrong.withValues(alpha: 0.4),
                        valueColor:
                            const AlwaysStoppedAnimation(AppColors.brandYellow),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    etaLabel,
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.brandYellow,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PendingConfirmationCard extends StatelessWidget {
  const _PendingConfirmationCard({required this.order});
  final ActiveOrder order;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'order-hero-${order.id}',
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
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
                    Text(order.title, style: AppTypography.titleMedium),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(orderStatusLabel(context.l10n, order.status),
                        style: AppTypography.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textDisabled),
            ],
          ),
        ),
      ),
    );
  }
}

class _CanceledCard extends StatelessWidget {
  const _CanceledCard({required this.order});
  final ActiveOrder order;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'order-hero-${order.id}',
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: AppRadii.lgAll,
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.title,
                style: AppTypography.titleMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                orderStatusLabel(context.l10n, order.status),
                style: AppTypography.bodySmall.copyWith(color: AppColors.error),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Placeholder used by the Skeletonizer loading shimmer. Never rendered
/// with real data — the skeletonizer paints over the text/progress shapes.
final ActiveOrder _skeletonOrder = ActiveOrder(
  id: 'skeleton',
  title: 'Loading service title',
  status: ActiveOrderStatus.inProgress,
  vehicleMake: 'Make',
  vehicleModel: 'Model',
  vehiclePlate: 'AA 0000 BB',
  progress: 0.5,
  eta: DateTime(2026, 1, 1, 12, 0),
  scheduledFor: null,
  totalUah: 0,
);
