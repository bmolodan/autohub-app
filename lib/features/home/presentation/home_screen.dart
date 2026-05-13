import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/util/date_format.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../orders/composition/orders_providers.dart';
import '../../orders/domain/active_order.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(ordersControllerProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('NESEMOS', style: AppTypography.titleMedium),
                ),
                IconButton(
                  onPressed: () {},
                  tooltip: 'Сповіщення',
                  icon: const Icon(
                    Icons.notifications_none_outlined,
                    semanticLabel: 'Сповіщення',
                  ),
                ),
                IconButton(
                  onPressed: () => context.push(AppRoutes.showcase),
                  tooltip: 'Design tokens (dev)',
                  icon: const Icon(
                    Icons.palette_outlined,
                    semanticLabel: 'Дизайн-токени (dev)',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Привіт,',
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
            Text('Богдане', style: AppTypography.headlineMedium),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: async.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => ErrorState(
                  onRetry: () => ref.invalidate(ordersControllerProvider),
                ),
                data: (orders) => orders.isEmpty
                    ? EmptyState(
                        icon: Icons.car_repair_outlined,
                        title: 'Поки тиша',
                        subtitle:
                            'Активних замовлень немає. Запишіться на сервіс — ми про все подбаємо.',
                        ctaLabel: '+ Записатись на СТО',
                        onCta: () => context.push(AppRoutes.bookingService),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: orders.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (_, i) => _OrderCard(order: orders[i]),
                      ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ElevatedButton(
              onPressed: () => context.push(AppRoutes.bookingService),
              child: const Text('+ Записатись'),
            ),
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
    final child = switch (order.status) {
      ActiveOrderStatus.inProgress => _InProgressCard(order: order),
      ActiveOrderStatus.pendingConfirmation =>
        _PendingConfirmationCard(order: order),
      ActiveOrderStatus.canceled => _CanceledCard(order: order),
    };
    return Semantics(
      button: true,
      label: '${order.statusLabel}. ${order.title}. ${order.vehicleSummary}',
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

    return Container(
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
            style: AppTypography.overline.copyWith(
              color: AppColors.brandYellow,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            order.title,
            style: AppTypography.titleLarge.copyWith(color: AppColors.onBlack),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            order.vehicleSummary,
            style:
                AppTypography.bodySmall.copyWith(color: AppColors.textDisabled),
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
    );
  }
}

class _PendingConfirmationCard extends StatelessWidget {
  const _PendingConfirmationCard({required this.order});
  final ActiveOrder order;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                Text(order.statusLabel, style: AppTypography.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textDisabled),
        ],
      ),
    );
  }
}

class _CanceledCard extends StatelessWidget {
  const _CanceledCard({required this.order});
  final ActiveOrder order;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            order.statusLabel,
            style: AppTypography.bodySmall.copyWith(color: AppColors.error),
          ),
        ],
      ),
    );
  }
}
