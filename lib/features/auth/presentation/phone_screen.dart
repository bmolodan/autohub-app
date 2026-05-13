import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/button_spinner.dart';
import '../../../l10n/l10n_extension.dart';
import '../composition/auth_providers.dart';

/// Phone number entry — step 1 of auth.
/// Calls [AuthController.requestCode] then navigates to OTP with the challenge id.
class PhoneScreen extends ConsumerStatefulWidget {
  const PhoneScreen({super.key});

  @override
  ConsumerState<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends ConsumerState<PhoneScreen> {
  final _phoneCtrl = TextEditingController();
  bool _consent = true;
  bool _submitting = false;

  String get _rawPhone => _phoneCtrl.text.replaceAll(' ', '');

  bool get _canSubmit => _consent && _rawPhone.length >= 9 && !_submitting;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _submitting = true);
    final phone = '+380$_rawPhone';
    try {
      final challenge =
          await ref.read(authControllerProvider.notifier).requestCode(phone);
      if (!mounted) return;
      context.go(
        '${AppRoutes.otp}'
        '?${QueryParams.challengeId}=${Uri.encodeComponent(challenge.id)}'
        '&${QueryParams.phone}=${Uri.encodeComponent(phone)}',
      );
    } on Object catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.l10n.errorGeneric)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Column(
                  children: [
                    const _BrandPin(),
                    const SizedBox(height: AppSpacing.sm),
                    Text(context.l10n.appName,
                        style: AppTypography.titleMedium),
                    Text(context.l10n.phoneBrandTagline,
                        style: AppTypography.overline),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(context.l10n.phoneGreeting,
                  style: AppTypography.headlineLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(
                context.l10n.phoneInstruction,
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xl),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.inputH),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadii.mdAll,
                ),
                child: Row(
                  children: [
                    Text(
                      '+380',
                      style: AppTypography.titleMedium
                          .copyWith(color: AppColors.textTertiary),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: TextField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [_UaPhoneFormatter()],
                        style: AppTypography.titleMedium,
                        decoration: InputDecoration(
                          hintText: context.l10n.phoneHint,
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
              ),
              if (kDebugMode) ...[
                const SizedBox(height: AppSpacing.sm),
                GestureDetector(
                  onTap: () {
                    _phoneCtrl.text = '67 123 45 67';
                    setState(() {});
                  },
                  child: Text(
                    context.l10n.phoneDevHint,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              Semantics(
                checked: _consent,
                label: context.l10n.phoneConsent,
                child: GestureDetector(
                  onTap: () => setState(() => _consent = !_consent),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.only(top: 2),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _consent
                              ? AppColors.brandYellow
                              : Colors.transparent,
                          borderRadius: AppRadii.xsAll,
                          border: Border.all(
                            color: _consent
                                ? AppColors.brandYellow
                                : AppColors.borderStrong,
                            width: 1.5,
                          ),
                        ),
                        child: _consent
                            ? const Icon(Icons.check,
                                size: 16, color: AppColors.brandBlack)
                            : null,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          context.l10n.phoneConsent,
                          style: AppTypography.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: _canSubmit ? _submit : null,
                child: _submitting
                    ? const ButtonSpinner()
                    : Text(context.l10n.phoneSubmit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Formats Ukrainian mobile numbers as "XX XXX XX XX" while typing.
/// Caps at 9 digits; strips any non-digit characters the user might paste.
class _UaPhoneFormatter extends TextInputFormatter {
  static const _groupSizes = [2, 3, 2, 2]; // 2+3+2+2 = 9

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final capped = digits.length > 9 ? digits.substring(0, 9) : digits;

    final buf = StringBuffer();
    var consumed = 0;
    for (final size in _groupSizes) {
      if (consumed >= capped.length) break;
      if (consumed > 0) buf.write(' ');
      final end = (consumed + size).clamp(0, capped.length);
      buf.write(capped.substring(consumed, end));
      consumed = end;
    }
    final formatted = buf.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _BrandPin extends StatelessWidget {
  const _BrandPin();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        width: 40,
        height: 50,
        child: CustomPaint(painter: _PinPainter()),
      ),
    );
  }
}

class _PinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final pinPath = Path()
      ..moveTo(w / 2, h)
      ..quadraticBezierTo(0, h * 0.65, 0, w / 2)
      ..arcToPoint(Offset(w, w / 2),
          radius: Radius.circular(w / 2), clockwise: true)
      ..quadraticBezierTo(w, h * 0.65, w / 2, h)
      ..close();
    canvas.drawPath(pinPath, Paint()..color = AppColors.brandBlack);

    canvas.drawCircle(
      Offset(w / 2, w / 2),
      w * 0.22,
      Paint()..color = AppColors.brandYellow,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
