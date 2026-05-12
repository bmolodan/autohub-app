import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../data/service_catalog.dart';

/// Step 1/3 of booking: pick a service from the catalog.
class ServicePickerScreen extends StatefulWidget {
  const ServicePickerScreen({super.key});

  @override
  State<ServicePickerScreen> createState() => _ServicePickerScreenState();
}

class _ServicePickerScreenState extends State<ServicePickerScreen> {
  String? _selectedId;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = _query.isEmpty
        ? serviceCatalog
        : serviceCatalog
            .where((s) => s.title.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('Запис · крок 1 з 3', style: AppTypography.bodySmall),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Що потрібно?', style: AppTypography.headlineMedium),
              const SizedBox(height: AppSpacing.md),
              TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: const InputDecoration(
                  hintText: 'Пошук послуги',
                  prefixIcon: Icon(Icons.search, size: 20),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (_, i) => _ServiceTile(
                    item: filtered[i],
                    selected: filtered[i].id == _selectedId,
                    onTap: () => setState(() => _selectedId = filtered[i].id),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: _selectedId == null
                    ? null
                    : () => context.push(
                          '${AppRoutes.bookingProblem}?serviceId=$_selectedId',
                        ),
                child: const Text('Далі'),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final ServiceCatalogItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? AppColors.brandYellow : AppColors.surface;
    final border = selected ? AppColors.brandYellow : AppColors.border;

    return Material(
      color: bg,
      borderRadius: AppRadii.lgAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.lgAll,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadii.lgAll,
            border: Border.all(color: border, width: 0.5),
          ),
          child: Row(
            children: [
              Icon(item.icon, size: 24, color: AppColors.textPrimary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: AppTypography.titleSmall),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      '~${item.durationMinutes} хв  ·  від ${item.priceFromUah} ₴',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle,
                    color: AppColors.brandBlack, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
