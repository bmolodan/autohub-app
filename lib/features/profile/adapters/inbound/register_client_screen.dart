import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/util/validators.dart';
import '../../../../core/widgets/button_spinner.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../composition/profile_providers.dart';

/// First-time onboarding form. Also reused as a profile-edit screen by
/// passing `editMode: true` — in that case the form prefills from the
/// current profile and submits with an "updated" snackbar without pushing
/// the Add Car flow.
class RegisterClientScreen extends ConsumerStatefulWidget {
  const RegisterClientScreen({super.key, this.editMode = false});

  final bool editMode;

  @override
  ConsumerState<RegisterClientScreen> createState() =>
      _RegisterClientScreenState();
}

class _RegisterClientScreenState extends ConsumerState<RegisterClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  bool _submitting = false;
  bool _prefilled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.editMode && !_prefilled) {
      final current = ref.read(clientProfileControllerProvider).value;
      if (current != null) {
        _prefilled = true;
        _name.text = current.name;
        _email.text = current.email ?? '';
      }
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    try {
      await ref.read(clientProfileControllerProvider.notifier).save(
            name: _name.text,
            email: _email.text,
          );
      if (!mounted) return;
      if (widget.editMode) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.registerUpdatedSnack)),
        );
        Navigator.of(context).pop();
      } else {
        // First-time onboarding: drop the registration off the stack and
        // open Add Car so the user lands with a vehicle ready.
        context.go(AppRoutes.home);
        unawaited(context.push(AppRoutes.carAdd));
      }
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

    String? validateName(String? v) =>
        requireNonEmpty(v, l.commonRequiredField);

    String? validateEmail(String? v) {
      if (v == null || v.trim().isEmpty) return null;
      return emailRegex.hasMatch(v.trim()) ? null : l.registerEmailInvalid;
    }

    return Scaffold(
      appBar: AppBar(
        // No back arrow on first-time onboarding — registration is required.
        // In edit mode the user can dismiss.
        leading: widget.editMode
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: Text(
          widget.editMode ? l.registerEditTitle : l.registerTitle,
          style: AppTypography.titleLarge,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l.registerHeading, style: AppTypography.headlineMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l.registerSubtitle,
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  validator: validateName,
                  decoration: InputDecoration(labelText: l.registerFieldName),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  validator: validateEmail,
                  decoration: InputDecoration(labelText: l.registerFieldEmail),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const ButtonSpinner()
                      : Text(widget.editMode
                          ? l.registerEditSubmit
                          : l.registerSubmit),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
