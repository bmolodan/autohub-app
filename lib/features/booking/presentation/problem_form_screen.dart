import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../cars/composition/cars_providers.dart';
import '../../orders/application/use_cases/create_order.dart';
import '../../orders/composition/orders_providers.dart';
import '../data/service_catalog.dart';

/// Step 3/3 of booking: describe the problem + attach photos.
class ProblemFormScreen extends ConsumerStatefulWidget {
  const ProblemFormScreen({super.key, required this.serviceId});
  final String serviceId;

  @override
  ConsumerState<ProblemFormScreen> createState() => _ProblemFormScreenState();
}

class _ProblemFormScreenState extends ConsumerState<ProblemFormScreen> {
  final _descController = TextEditingController();
  int _photos = 2;
  bool _submitting = false;

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  ServiceCatalogItem? get _service =>
      serviceCatalog.where((s) => s.id == widget.serviceId).firstOrNull;

  Future<void> _submit() async {
    if (_submitting) return;
    final service = _service;
    if (service == null) return;

    final vehicles = ref.read(vehiclesControllerProvider).value;
    if (vehicles == null || vehicles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Спочатку додайте авто')),
      );
      unawaited(context.push(AppRoutes.carAdd));
      return;
    }

    setState(() => _submitting = true);
    try {
      final created = await ref.read(ordersControllerProvider.notifier).create(
            CreateOrderInput(
              serviceTitle: service.title,
              servicePriceUah: service.priceFromUah,
              description: _descController.text.trim(),
              vehicle: vehicles.first,
            ),
          );
      if (!mounted) return;
      context.go('${AppRoutes.orderDetail}/${created.id}');
    } on Object catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = _service;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('Запис · крок 3 з 3', style: AppTypography.bodySmall),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Що сталось?', style: AppTypography.headlineMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Опишіть проблему',
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _descController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText:
                      'Стук у передній підвісці на нерівностях. Зʼявляється після прогрівання…',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Фото ($_photos / 3)',
                style: AppTypography.labelMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  for (int i = 0; i < 3; i++) ...[
                    Expanded(
                      child: _PhotoSlot(
                        filled: i < _photos,
                        onTap: () => setState(() {
                          if (i < _photos) {
                            _photos = i;
                          } else if (_photos < 3) {
                            _photos++;
                          }
                        }),
                      ),
                    ),
                    if (i < 2) const SizedBox(width: AppSpacing.sm),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _SummaryRow(label: 'Послуга', value: service?.title ?? '—'),
              _SummaryRow(label: 'Авто', value: _vehicleLabel()),
              _SummaryRow(
                label: 'Орієнтовно',
                value: 'від ${service?.priceFromUah ?? 0} ₴',
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Підтвердити запис'),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  String _vehicleLabel() {
    final v = ref.watch(vehiclesControllerProvider).value;
    if (v == null || v.isEmpty) return '—';
    final car = v.first;
    return '${car.make} ${car.model}';
  }
}

class _PhotoSlot extends StatelessWidget {
  const _PhotoSlot({required this.filled, required this.onTap});
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: filled ? 'Видалити фото' : 'Додати фото',
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.mdAll,
        child: AspectRatio(
          aspectRatio: 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: filled ? AppColors.surfaceVariant : AppColors.surface,
              borderRadius: AppRadii.mdAll,
              border: Border.all(color: AppColors.borderStrong, width: 0.5),
            ),
            child: Icon(
              filled ? Icons.image_outlined : Icons.add,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.textSecondary),
            ),
          ),
          Text(value, style: AppTypography.labelMedium),
        ],
      ),
    );
  }
}
