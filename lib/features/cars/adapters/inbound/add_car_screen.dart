import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/util/ua_plate_formatter.dart';
import '../../../../core/util/validators.dart';
import '../../../../core/widgets/button_spinner.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../application/use_cases/add_vehicle.dart';
import '../../application/use_cases/update_vehicle.dart';
import '../../composition/cars_providers.dart';
import '../../data/car_catalog.dart';
import '../../domain/vehicle.dart';

class AddCarScreen extends ConsumerStatefulWidget {
  const AddCarScreen({super.key, this.editVehicleId, this.nextRoute});

  /// When non-null, the screen is in edit mode: it pre-fills the form
  /// with the vehicle's current values and updates instead of inserting.
  final String? editVehicleId;

  /// When non-null, on successful save the user is redirected to
  /// [nextRoute] instead of popping back. Used by the empty-vehicles
  /// booking redirect: Home → Add Car → Service Picker without an
  /// awkward intermediate pop.
  final String? nextRoute;

  @override
  ConsumerState<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends ConsumerState<AddCarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vin = TextEditingController();
  final _make = TextEditingController();
  final _model = TextEditingController();
  final _year = TextEditingController();
  final _plate = TextEditingController();
  bool _submitting = false;
  bool _prefilled = false;

  bool get _isEditing => widget.editVehicleId != null;

  @override
  void dispose() {
    _vin.dispose();
    _make.dispose();
    _model.dispose();
    _year.dispose();
    _plate.dispose();
    super.dispose();
  }

  void _prefillFrom(Vehicle v) {
    if (_prefilled) return;
    _prefilled = true;
    _make.text = v.make;
    _model.text = v.model;
    _year.text = v.year.toString();
    _plate.text = v.plate;
    _vin.text = v.vin ?? '';
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    try {
      final controller = ref.read(vehiclesControllerProvider.notifier);
      if (_isEditing) {
        await controller.edit(
          UpdateVehicleInput(
            id: widget.editVehicleId!,
            make: _make.text,
            model: _model.text,
            year: int.parse(_year.text),
            plate: _plate.text,
            vin: _vin.text,
          ),
        );
      } else {
        await controller.add(
          AddVehicleInput(
            make: _make.text,
            model: _model.text,
            year: int.parse(_year.text),
            plate: _plate.text,
            vin: _vin.text,
          ),
        );
      }
      if (!mounted) return;
      final snackText = _isEditing ? context.l10n.carUpdateSuccessSnack : null;
      if (snackText != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(snackText)),
        );
      }
      final next = widget.nextRoute;
      if (next != null && next.isNotEmpty) {
        context.go(next);
      } else {
        context.pop();
      }
    } on Object catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.l10n.errorGeneric)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _pickMake(CarCatalog catalog) async {
    final l = context.l10n;
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _PickerSheet(
        title: l.addCarFieldMake,
        items: catalog.makes,
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        _make.text = picked;
        _model.clear();
      });
    }
  }

  Future<void> _pickModel(CarCatalog catalog) async {
    final l = context.l10n;
    final make = _make.text.trim();
    if (!catalog.hasMake(make)) return;
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _PickerSheet(
        title: l.addCarFieldModel,
        items: catalog.modelsFor(make),
      ),
    );
    if (picked != null && mounted) {
      setState(() => _model.text = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final catalogAsync = ref.watch(carCatalogProvider);

    if (_isEditing) {
      // Pre-fill on first build from the current vehicle, if available.
      final v = ref.watch(vehicleByIdProvider(widget.editVehicleId!)).value;
      if (v != null) _prefillFrom(v);
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _isEditing ? l.addCarEditTitle : l.carsAddCta,
          style: AppTypography.titleLarge,
        ),
      ),
      body: SafeArea(
        child: catalogAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text(context.l10n.carsLoadFailed(e.toString()),
                style: AppTypography.bodyMedium),
          ),
          data: (catalog) => _buildForm(context, catalog),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, CarCatalog catalog) {
    final l = context.l10n;

    String? validYear(String? v) {
      final base = requireNonEmpty(v, l.commonRequiredField);
      if (base != null) return base;
      final y = int.tryParse(v!);
      if (y == null) return l.commonNumbersOnly;
      final max = DateTime.now().year + 1;
      if (y < 1900 || y > max) return l.addCarYearRange(max);
      return null;
    }

    String? validateMake(String? v) {
      final base = requireNonEmpty(v, l.commonRequiredField);
      if (base != null) return base;
      return catalog.hasMake(v!.trim()) ? null : l.addCarMakeUnknown;
    }

    String? validateModel(String? v) {
      final base = requireNonEmpty(v, l.commonRequiredField);
      if (base != null) return base;
      final make = _make.text.trim();
      return catalog.hasModel(make, v!.trim()) ? null : l.addCarModelUnknown;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _isEditing ? l.addCarEditHeading : l.addCarHeading,
              style: AppTypography.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l.addCarSubtitle,
              style: AppTypography.bodySmall
                  .copyWith(color: context.colors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _vin,
              // VIN spec is exactly 17 chars; cap to prevent garbage input.
              maxLength: 17,
              decoration: InputDecoration(
                labelText: l.addCarFieldVin,
                counterText: '',
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _make,
                    readOnly: true,
                    onTap: () => _pickMake(catalog),
                    validator: validateMake,
                    decoration: InputDecoration(
                      labelText: l.addCarFieldMake,
                      suffixIcon: Icon(Icons.arrow_drop_down,
                          color: context.colors.textSecondary),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextFormField(
                    controller: _model,
                    readOnly: true,
                    onTap: () => _pickModel(catalog),
                    validator: validateModel,
                    decoration: InputDecoration(
                      labelText: l.addCarFieldModel,
                      suffixIcon: Icon(Icons.arrow_drop_down,
                          color: context.colors.textSecondary),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _year,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    validator: validYear,
                    decoration: InputDecoration(labelText: l.addCarFieldYear),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextFormField(
                    controller: _plate,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: const [UaPlateInputFormatter()],
                    validator: (v) => validateUaPlate(
                      v,
                      requiredMessage: l.commonRequiredField,
                      invalidMessage: l.addCarPlateInvalid,
                    ),
                    decoration: InputDecoration(
                      labelText: l.addCarFieldPlate,
                      hintText: l.addCarPlateHint,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const ButtonSpinner()
                  : Text(_isEditing ? l.addCarUpdateSave : l.addCarSave),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

/// Bottom-sheet picker with a typeahead search field at the top — used for
/// both make and model pickers. Returns the selected string via pop().
class _PickerSheet extends StatefulWidget {
  const _PickerSheet({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  State<_PickerSheet> createState() => _PickerSheetState();
}

class _PickerSheetState extends State<_PickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = _query.isEmpty
        ? widget.items
        : widget.items
            .where((m) => m.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: viewInsets),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: Text(widget.title, style: AppTypography.titleLarge),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: TextField(
                  autofocus: true,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search, size: AppIconSize.md),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final value = filtered[i];
                    return InkWell(
                      onTap: () => Navigator.of(context).pop(value),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.sm,
                        ),
                        child: Text(value, style: AppTypography.titleSmall),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
