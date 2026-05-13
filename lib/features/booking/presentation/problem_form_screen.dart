import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/l10n_extension.dart';
import '../../cars/composition/cars_providers.dart';
import '../../orders/application/use_cases/create_order.dart';
import '../../orders/composition/orders_providers.dart';
import '../../orders/domain/order_photo.dart';
import '../data/service_catalog.dart';
import 'service_l10n.dart';

const _maxPhotos = 3;

/// Step 3/3 of booking: describe the problem + attach photos.
class ProblemFormScreen extends ConsumerStatefulWidget {
  const ProblemFormScreen({super.key, required this.serviceId});
  final String serviceId;

  @override
  ConsumerState<ProblemFormScreen> createState() => _ProblemFormScreenState();
}

class _ProblemFormScreenState extends ConsumerState<ProblemFormScreen> {
  final _descController = TextEditingController();
  final List<OrderPhoto> _photos = [];
  bool _submitting = false;
  bool _pickingPhoto = false;

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  ServiceCatalogItem? get _service =>
      serviceCatalog.where((s) => s.id == widget.serviceId).firstOrNull;

  Future<void> _addPhoto() async {
    if (_pickingPhoto || _photos.length >= _maxPhotos) return;
    _pickingPhoto = true;
    final l = context.l10n;
    final source = await showModalBottomSheet<_PhotoSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l.photoSourceCamera),
              onTap: () => Navigator.of(ctx).pop(_PhotoSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l.photoSourceGallery),
              onTap: () => Navigator.of(ctx).pop(_PhotoSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: Text(l.commonCancel),
              onTap: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    final port = ref.read(photoStorageProvider);
    try {
      final picked = switch (source) {
        _PhotoSource.camera => await port.pickFromCamera(),
        _PhotoSource.gallery => await port.pickFromGallery(),
      };
      if (picked == null || !mounted) return;
      setState(() => _photos.add(picked));
    } on Object catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.photoAddError(e.toString()))),
      );
    } finally {
      _pickingPhoto = false;
    }
  }

  Future<void> _removePhoto(int index) async {
    final removed = _photos[index];
    setState(() => _photos.removeAt(index));
    try {
      await ref.read(photoStorageProvider).remove(removed);
    } on Object catch (_) {
      // Best-effort delete; ignore I/O failures.
    }
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final service = _service;
    if (service == null) return;

    final vehicles = ref.read(vehiclesControllerProvider).value;
    if (vehicles == null || vehicles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.problemNoVehicleSnack)),
      );
      unawaited(context.push(AppRoutes.carAdd));
      return;
    }

    setState(() => _submitting = true);
    try {
      final created = await ref.read(ordersControllerProvider.notifier).create(
            CreateOrderInput(
              serviceTitle: serviceTitle(context.l10n, service.id),
              servicePriceUah: service.priceFromUah,
              description: _descController.text.trim(),
              vehicle: vehicles.first,
              photos: List.unmodifiable(_photos),
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
    final l = context.l10n;
    final service = _service;
    final vehicles = ref.watch(vehiclesControllerProvider).value;
    final vehicleLabel = vehicles == null || vehicles.isEmpty
        ? '—'
        : '${vehicles.first.make} ${vehicles.first.model}';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(l.bookingStep3Title, style: AppTypography.bodySmall),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.problemHeading, style: AppTypography.headlineMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l.problemSubtitle,
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _descController,
                maxLines: 4,
                decoration: InputDecoration(hintText: l.problemHint),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l.problemPhotosCount(_photos.length, _maxPhotos),
                style: AppTypography.labelMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  for (int i = 0; i < _maxPhotos; i++) ...[
                    Expanded(
                      child: i < _photos.length
                          ? _PhotoSlot.filled(
                              photo: _photos[i],
                              onRemove: () => _removePhoto(i),
                            )
                          : _PhotoSlot.empty(onAdd: _addPhoto),
                    ),
                    if (i < _maxPhotos - 1)
                      const SizedBox(width: AppSpacing.sm),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _SummaryRow(
                label: l.problemSummaryService,
                value: service != null ? serviceTitle(l, service.id) : '—',
              ),
              _SummaryRow(label: l.problemSummaryVehicle, value: vehicleLabel),
              _SummaryRow(
                label: l.problemSummaryEstimate,
                value: l.problemEstimateFrom(service?.priceFromUah ?? 0),
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
                    : Text(l.problemSubmit),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

enum _PhotoSource { camera, gallery }

class _PhotoSlot extends StatelessWidget {
  const _PhotoSlot.empty({required VoidCallback this.onAdd})
      : photo = null,
        onRemove = null;
  const _PhotoSlot.filled({
    required OrderPhoto this.photo,
    required VoidCallback this.onRemove,
  }) : onAdd = null;

  final OrderPhoto? photo;
  final VoidCallback? onAdd;
  final VoidCallback? onRemove;

  bool get _filled => photo != null;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: _filled
          ? context.l10n.photoRemoveSemantics
          : context.l10n.photoAddSemantics,
      child: InkWell(
        onTap: _filled ? onRemove : onAdd,
        borderRadius: AppRadii.mdAll,
        child: AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: AppRadii.mdAll,
            child: _filled
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(
                        File(photo!.localPath),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const ColoredBox(
                          color: AppColors.surfaceVariant,
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: AppColors.brandBlack,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close,
                              size: 14, color: AppColors.onBlack),
                        ),
                      ),
                    ],
                  )
                : DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadii.mdAll,
                      border: Border.all(
                        color: AppColors.borderStrong,
                        width: 0.5,
                      ),
                    ),
                    child:
                        const Icon(Icons.add, color: AppColors.textSecondary),
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
