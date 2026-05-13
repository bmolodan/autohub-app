import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/l10n_extension.dart';
import '../data/service_catalog.dart';
import 'service_l10n.dart';

/// Step 1/3 of booking: pick a service from the catalog.
class ServicePickerScreen extends StatefulWidget {
  const ServicePickerScreen({super.key});

  @override
  State<ServicePickerScreen> createState() => _ServicePickerScreenState();
}

class _ServicePickerScreenState extends State<ServicePickerScreen> {
  String? _selectedId;
  String _query = '';

  Future<void> _openCustomSheet() async {
    final ctrl = TextEditingController();
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final l = ctx.l10n;
        final viewInsets = MediaQuery.of(ctx).viewInsets.bottom;
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: viewInsets),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l.bookingPickerCustomSheetTitle,
                      style: AppTypography.headlineSmall),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: ctrl,
                    autofocus: true,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: l.bookingPickerCustomFieldLabel,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton(
                    onPressed: () {
                      final text = ctrl.text.trim();
                      if (text.isEmpty) return;
                      Navigator.of(ctx).pop(text);
                    },
                    child: Text(l.bookingPickerCustomSubmit),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (!mounted || picked == null) return;
    unawaited(context.push(
      '${AppRoutes.bookingProblem}?customTitle=${Uri.encodeQueryComponent(picked)}',
    ));
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _query.isEmpty
        ? serviceCatalog
        : serviceCatalog
            .where((s) => serviceTitle(context.l10n, s.id)
                .toLowerCase()
                .contains(_query.toLowerCase()))
            .toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(context.l10n.bookingStep1Title,
            style: AppTypography.bodySmall),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(context.l10n.bookingPickerHeading,
                  style: AppTypography.headlineMedium),
              const SizedBox(height: AppSpacing.md),
              TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: context.l10n.bookingPickerSearchHint,
                  prefixIcon: const Icon(Icons.search, size: AppIconSize.md),
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
              TextButton(
                onPressed: _openCustomSheet,
                child: Text(context.l10n.bookingPickerCustomCta),
              ),
              const SizedBox(height: AppSpacing.sm),
              FilledButton(
                onPressed: _selectedId == null
                    ? null
                    : () => context.push(
                          '${AppRoutes.bookingProblem}?serviceId=$_selectedId',
                        ),
                child: Text(context.l10n.commonNext),
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
              Icon(item.icon,
                  size: AppIconSize.xl, color: AppColors.textPrimary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(serviceTitle(context.l10n, item.id),
                        style: AppTypography.titleSmall),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      context.l10n.bookingServiceDurationAndPrice(
                        item.durationMinutes,
                        item.priceFromUah,
                      ),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle,
                    color: AppColors.brandBlack, size: AppIconSize.lg),
            ],
          ),
        ),
      ),
    );
  }
}
