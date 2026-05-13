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
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _CustomServiceSheet(),
    );
    if (!mounted || picked == null) return;
    // Clear catalog selection so the picker's _Selected-state can't push a
    // stale "Далі" navigation alongside the custom-title push we are about
    // to make.
    setState(() => _selectedId = null);
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

const int _kMaxCustomTitleLength = 80;

/// Modal-sheet body for the "name your own service" path. Lives as a
/// StatefulWidget so the controller is disposed when the sheet pops —
/// the previous inline approach leaked a `TextEditingController` on
/// every open.
class _CustomServiceSheet extends StatefulWidget {
  const _CustomServiceSheet();

  @override
  State<_CustomServiceSheet> createState() => _CustomServiceSheetState();
}

class _CustomServiceSheetState extends State<_CustomServiceSheet> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: keyboardInset),
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
                controller: _ctrl,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                maxLength: _kMaxCustomTitleLength,
                decoration: InputDecoration(
                  labelText: l.bookingPickerCustomFieldLabel,
                  counterText: '',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: () {
                  final text = _ctrl.text.trim();
                  if (text.isEmpty) return;
                  Navigator.of(context).pop(text);
                },
                child: Text(l.bookingPickerCustomSubmit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
