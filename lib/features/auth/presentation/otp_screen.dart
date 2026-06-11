import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/brand_colors.dart';
import '../../../core/widgets/button_spinner.dart';
import '../../../l10n/l10n_extension.dart';
import '../application/ports/outbound/otp_gateway_port.dart';
import '../composition/auth_providers.dart';

/// 4-digit OTP entry. Calls [AuthController.verifyCode]; on success the
/// session is persisted and the router redirects to /home.
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, required this.phone, required this.challengeId});

  final String phone;
  final String challengeId;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> with WidgetsBindingObserver {
  static const _resendDelaySeconds = 54;

  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  Timer? _resendTimer;
  int _secondsLeft = _resendDelaySeconds;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startCountdown();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When the user returns from the SMS app or any other foreground swap,
    // Flutter doesn't restore focus to the hidden OTP TextField. Re-request
    // it on resume so the keyboard reappears — but only when the user still
    // needs to enter the code.
    if (state == AppLifecycleState.resumed && !_submitting && _ctrl.text.length < 6) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _refocusKeyboard();
      });
    }
  }

  /// Forces the IME to reappear. Calling requestFocus on a node that already
  /// has focus is a no-op (and the Android keyboard stays dismissed after the
  /// user swipes it down), so we unfocus first, then refocus next frame.
  void _refocusKeyboard() {
    if (!mounted) return;
    _focus.unfocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  void _startCountdown() {
    _resendTimer?.cancel();
    setState(() => _secondsLeft = _resendDelaySeconds);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _resendTimer?.cancel();
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_ctrl.text.length != 6 || _submitting) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).verifyCode(
            challengeId: widget.challengeId,
            code: _ctrl.text,
          );
      if (!mounted) return;
      context.go(AppRoutes.home);
    } on InvalidOtpException catch (e) {
      if (!mounted) return;
      final l = context.l10n;
      setState(() {
        _error = switch (e.reason) {
          InvalidOtpReason.expired => l.otpExpiredCode,
          InvalidOtpReason.wrongCode => l.otpInvalidCode,
        };
        _ctrl.clear();
      });
    } on Object catch (_) {
      if (!mounted) return;
      setState(() => _error = context.l10n.errorGeneric);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _maskedPhone() {
    final p = widget.phone;
    if (p.length < 9) return p;
    return '${p.substring(0, 7)} ••• ${p.substring(p.length - 2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // OTP screen is reached via context.go() which replaces the stack, so
      // Navigator.maybePop has nothing to pop. Wire the back button explicitly
      // to the phone screen.
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go(AppRoutes.phone)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(context.l10n.otpTitle, style: AppTypography.headlineLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(_maskedPhone(),
                  style: AppTypography.bodyMedium
                      .copyWith(color: context.colors.textSecondary)),
              const SizedBox(height: AppSpacing.xxl),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _refocusKeyboard,
                child: Row(
                  children: List.generate(6, (i) {
                    final has = _ctrl.text.length > i;
                    final isCurrent = _ctrl.text.length == i;
                    final hasError = _error != null;
                    return Expanded(
                      child: Container(
                        margin:
                            EdgeInsets.only(right: i < 5 ? AppSpacing.xs : 0),
                        height: AppSizes.otpSlotHeight,
                        decoration: BoxDecoration(
                          color: context.colors.surface,
                          borderRadius: AppRadii.mdAll,
                          border: hasError
                              ? Border.all(
                                  color: context.colors.error, width: 2)
                              : isCurrent
                                  ? Border.all(
                                      color: context.colors.brandYellow,
                                      width: 2)
                                  : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          has ? _ctrl.text[i] : '',
                          style: AppTypography.displayMedium,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              // Zero-sized + clipped so Android's IME keeps the input client
              // attached while nothing is painted. SizedBox alone constrains
              // layout but not painting — ClipRect clips the overflow.
              ClipRect(
                child: SizedBox(
                  width: 0,
                  height: 0,
                  child: TextField(
                    controller: _ctrl,
                    focusNode: _focus,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration.collapsed(hintText: ''),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    onChanged: (v) {
                      setState(() => _error = null);
                      if (v.length == 6) _submit();
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (_error != null)
                Text(_error!,
                    style: AppTypography.bodySmall
                        .copyWith(color: context.colors.error)),
              const SizedBox(height: AppSpacing.md),
              Center(
                child: _secondsLeft > 0
                    ? Text(
                        context.l10n.otpResendIn(
                          _secondsLeft.toString().padLeft(2, '0'),
                        ),
                        style: AppTypography.bodySmall
                            .copyWith(color: context.colors.textSecondary))
                    : TextButton(
                        onPressed: _startCountdown,
                        child: Text(context.l10n.otpResendNow),
                      ),
              ),
              const Spacer(),
              FilledButton(
                onPressed:
                    _ctrl.text.length == 6 && !_submitting ? _submit : null,
                child: _submitting
                    ? const ButtonSpinner()
                    : Text(context.l10n.otpSubmit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
