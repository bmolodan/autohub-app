import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../application/use_cases/add_vehicle.dart';
import '../../composition/cars_providers.dart';

class AddCarScreen extends ConsumerStatefulWidget {
  const AddCarScreen({super.key});

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

  @override
  void dispose() {
    _vin.dispose();
    _make.dispose();
    _model.dispose();
    _year.dispose();
    _plate.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    try {
      await ref.read(vehiclesControllerProvider.notifier).add(
            AddVehicleInput(
              make: _make.text,
              model: _model.text,
              year: int.parse(_year.text),
              plate: _plate.text,
              vin: _vin.text,
            ),
          );
      if (!mounted) return;
      context.pop();
    } on Object catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('Додати авто', style: AppTypography.titleLarge),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Розкажіть про вашу машину',
                    style: AppTypography.headlineMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Можна заповнити VIN — решта заповниться автоматично',
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _vin,
                  decoration: const InputDecoration(labelText: 'VIN (опційно)'),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _make,
                        validator: _required,
                        decoration: const InputDecoration(labelText: 'Марка'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: TextFormField(
                        controller: _model,
                        validator: _required,
                        decoration: const InputDecoration(labelText: 'Модель'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _year,
                        keyboardType: TextInputType.number,
                        validator: _validYear,
                        decoration: const InputDecoration(labelText: 'Рік'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: TextFormField(
                        controller: _plate,
                        validator: _required,
                        decoration: const InputDecoration(labelText: 'Номер'),
                      ),
                    ),
                  ],
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
                      : const Text('Зберегти авто'),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Обовʼязкове поле' : null;

  static String? _validYear(String? v) {
    if (v == null || v.trim().isEmpty) return 'Обовʼязкове поле';
    final y = int.tryParse(v);
    if (y == null) return 'Тільки число';
    final max = DateTime.now().year + 1;
    if (y < 1900 || y > max) return '1900–$max';
    return null;
  }
}
