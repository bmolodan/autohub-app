import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/brand_colors.dart';
import '../../../core/util/date_format.dart';
import '../../../core/widgets/button_spinner.dart';
import '../../../l10n/l10n_extension.dart';
import '../../cars/composition/cars_providers.dart';
import '../../cars/domain/vehicle.dart';
import '../../orders/application/use_cases/create_order.dart';
import '../../orders/composition/orders_providers.dart';
import '../../orders/domain/order_photo.dart';

const _maxPhotos = 3;

/// Single-screen client booking: describe the problem, optionally attach
/// photos, pick a vehicle, optionally pick a preferred date/time. No
/// service catalog and no client-side pricing — the manager assigns
/// services and price after intake.
class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  final _descController = TextEditingController();
  final List<OrderPhoto> _photos = [];
  bool _submitting = false;
  bool _pickingPhoto = false;
  String? _selectedVehicleId;
  DateTime? _preferredAt;

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

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
    final remaining = _maxPhotos - _photos.length;
    try {
      switch (source) {
        case _PhotoSource.camera:
          final picked = await port.pickFromCamera();
          if (picked == null || !mounted) return;
          setState(() => _photos.add(picked));
        case _PhotoSource.gallery:
          final picked = await port.pickMultipleFromGallery(limit: remaining);
          if (picked.isEmpty || !mounted) return;
          setState(() => _photos.addAll(picked));
      }
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

  Vehicle? _resolveSelected(List<Vehicle> vehicles) {
    if (vehicles.isEmpty) return null;
    final id = _selectedVehicleId;
    if (id != null) {
      for (final v in vehicles) {
        if (v.id == id) return v;
      }
    }
    return vehicles.first;
  }

  Future<void> _openVehicleSheet(List<Vehicle> vehicles) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) {
        final l = ctx.l10n;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(
                  l.problemVehiclePickerTitle,
                  style: AppTypography.titleLarge,
                ),
              ),
              for (final v in vehicles)
                ListTile(
                  leading: const Icon(Icons.directions_car_outlined),
                  title: Text('${v.make} ${v.model}',
                      style: AppTypography.titleSmall),
                  subtitle: Text(
                    '${v.year} · ${v.plate}',
                    style: AppTypography.bodySmall
                        .copyWith(color: ctx.colors.textSecondary),
                  ),
                  trailing: v.id == _selectedVehicleId ||
                          (_selectedVehicleId == null &&
                              v.id == vehicles.first.id)
                      ? Icon(Icons.check, color: ctx.colors.brandBlack)
                      : null,
                  onTap: () => Navigator.of(ctx).pop(v.id),
                ),
            ],
          ),
        );
      },
    );
    if (picked != null && mounted) {
      setState(() => _selectedVehicleId = picked);
    }
  }

  Future<void> _pickPreferredDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
      initialDate: _preferredAt ?? now,
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_preferredAt ?? now),
    );
    if (time == null || !mounted) return;
    setState(() {
      _preferredAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final l = context.l10n;

    final vehicles = ref.read(vehiclesControllerProvider).value;
    final selected = vehicles == null ? null : _resolveSelected(vehicles);
    if (selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.problemNoVehicleSnack)),
      );
      unawaited(context.push(AppRoutes.carAdd));
      return;
    }

    setState(() => _submitting = true);
    try {
      final created = await ref.read(ordersControllerProvider.notifier).create(
            CreateOrderInput(
              title: l.bookingPlaceholderTitle,
              description: _descController.text.trim(),
              vehicle: selected,
              scheduledFor: _preferredAt,
              photos: List.unmodifiable(_photos),
            ),
          );
      if (!mounted) return;
      // Reset to Home so the entire booking sub-stack is unwound, then push
      // the detail so the AppBar back arrow lands back on Home.
      context.go(AppRoutes.home);
      unawaited(context.push('${AppRoutes.orderDetail}/${created.id}'));
    } on Object catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.errorGeneric)),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final vehicles = ref.watch(vehiclesControllerProvider).value;
    final selected = vehicles == null ? null : _resolveSelected(vehicles);
    final canPickVehicle = vehicles != null && vehicles.length >= 2;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(l.bookingTitle, style: AppTypography.titleLarge),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  children: [
                    Text(l.problemHeading, style: AppTypography.headlineMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l.problemSubtitle,
                      style: AppTypography.bodySmall
                          .copyWith(color: context.colors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _descController,
                      maxLines: 4,
                      // Cap so a pasted megabyte doesn't end up in the order
                      // JSON; 1000 chars is generous for free-text description
                      // while still bounded for storage / transport.
                      maxLength: 1000,
                      decoration: InputDecoration(
                        hintText: l.problemHint,
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      l.problemPhotosCount(_photos.length, _maxPhotos),
                      style: AppTypography.labelMedium
                          .copyWith(color: context.colors.textSecondary),
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
                    _SectionLabel(text: l.bookingVehicleSectionLabel),
                    const SizedBox(height: AppSpacing.sm),
                    _VehicleTile(
                      vehicle: selected,
                      onTap: canPickVehicle
                          ? () => _openVehicleSheet(vehicles)
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _SectionLabel(text: l.bookingDateSectionLabel),
                    const SizedBox(height: AppSpacing.sm),
                    _DateRow(
                      preferredAt: _preferredAt,
                      onPick: _pickPreferredDate,
                      onClear: () => setState(() => _preferredAt = null),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child:
                    _submitting ? const ButtonSpinner() : Text(l.problemSubmit),
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style:
          AppTypography.overline.copyWith(color: context.colors.textSecondary),
    );
  }
}

/// Card-sized vehicle picker. Non-interactive when [onTap] is null
/// (single-vehicle case).
class _VehicleTile extends StatelessWidget {
  const _VehicleTile({required this.vehicle, required this.onTap});

  final Vehicle? vehicle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final v = vehicle;
    final body = Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: context.colors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: AppSizes.avatar,
            height: AppSizes.avatar,
            decoration: BoxDecoration(
              color: context.colors.surfaceVariant,
              borderRadius: AppRadii.mdAll,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.directions_car_outlined,
              color: context.colors.textPrimary,
              size: AppIconSize.xl,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  v == null ? l.problemNoVehicleSnack : '${v.make} ${v.model}',
                  style: AppTypography.titleMedium,
                ),
                if (v != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    '${v.year} · ${v.plate}',
                    style: AppTypography.bodySmall
                        .copyWith(color: context.colors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          if (onTap != null)
            Icon(Icons.chevron_right,
                color: context.colors.textDisabled, size: AppIconSize.md),
        ],
      ),
    );

    if (onTap == null) return body;
    return Semantics(
      button: true,
      label: v == null ? l.problemNoVehicleSnack : '${v.make} ${v.model}',
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.lgAll,
        child: body,
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow({
    required this.preferredAt,
    required this.onPick,
    required this.onClear,
  });

  final DateTime? preferredAt;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final hasPick = preferredAt != null;
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _Chip(
          label: l.bookingDateNearestChip,
          selected: !hasPick,
          onTap: hasPick ? onClear : null,
        ),
        if (hasPick)
          _Chip(
            label: formatDdMmHm(preferredAt!),
            selected: true,
            trailing: Icon(Icons.close,
                size: AppIconSize.sm, color: context.colors.onYellow),
            trailingSemantics: l.bookingDateClearSemantics,
            onTap: onClear,
          )
        else
          _Chip(
            label: l.bookingDatePickHint,
            selected: false,
            onTap: onPick,
            leading: Icon(Icons.calendar_today_outlined,
                size: AppIconSize.sm, color: context.colors.textPrimary),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    this.onTap,
    this.leading,
    this.trailing,
    this.trailingSemantics,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final Widget? leading;
  final Widget? trailing;
  final String? trailingSemantics;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final bg = selected ? c.brandYellow : c.surface;
    final fg = selected ? c.onYellow : c.textPrimary;
    final border = selected ? c.brandYellow : c.border;
    final tile = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadii.pillAll,
        border: Border.all(color: border, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(label, style: AppTypography.labelMedium.copyWith(color: fg)),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.xs),
            trailing!,
          ],
        ],
      ),
    );
    if (onTap == null) return tile;
    return Semantics(
      button: true,
      label: trailingSemantics ?? label,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.pillAll,
        child: tile,
      ),
    );
  }
}

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
                        errorBuilder: (_, __, ___) => ColoredBox(
                          color: context.colors.surfaceVariant,
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: context.colors.brandBlack,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close,
                              size: 14, color: context.colors.onBlack),
                        ),
                      ),
                    ],
                  )
                : DecoratedBox(
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      borderRadius: AppRadii.mdAll,
                      border: Border.all(
                        color: context.colors.borderStrong,
                        width: 0.5,
                      ),
                    ),
                    child: Icon(Icons.add, color: context.colors.textSecondary),
                  ),
          ),
        ),
      ),
    );
  }
}
