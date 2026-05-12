import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/shared_prefs_provider.dart';
import '../adapters/outbound/fake_otp_gateway.dart';
import '../adapters/outbound/shared_prefs_session_storage.dart';
import '../application/ports/outbound/otp_gateway_port.dart';
import '../application/ports/outbound/session_storage_port.dart';
import '../application/use_cases/request_otp.dart';
import '../application/use_cases/sign_out.dart';
import '../application/use_cases/verify_otp.dart';
import '../domain/session.dart';

/// Composition root for auth.
final otpGatewayProvider = Provider<OtpGatewayPort>((_) => FakeOtpGateway());

final sessionStorageProvider = Provider<SessionStoragePort>(
  (ref) => SharedPrefsSessionStorage(ref.watch(sharedPreferencesProvider)),
);

final requestOtpUseCaseProvider = Provider<RequestOtpUseCase>(
  (ref) => RequestOtpUseCase(ref.watch(otpGatewayProvider)),
);

final verifyOtpUseCaseProvider = Provider<VerifyOtpUseCase>(
  (ref) => VerifyOtpUseCase(
    ref.watch(otpGatewayProvider),
    ref.watch(sessionStorageProvider),
  ),
);

final signOutUseCaseProvider = Provider<SignOutUseCase>(
  (ref) => SignOutUseCase(ref.watch(sessionStorageProvider)),
);

/// View-model: the current session. Null when signed out.
class AuthController extends AsyncNotifier<Session?> {
  @override
  Future<Session?> build() => ref.watch(sessionStorageProvider).read();

  Future<OtpChallenge> requestCode(String phone) {
    return ref.read(requestOtpUseCaseProvider).execute(
          RequestOtpInput(phone: phone),
        );
  }

  Future<void> verifyCode({
    required String challengeId,
    required String code,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return ref.read(verifyOtpUseCaseProvider).execute(
            VerifyOtpInput(challengeId: challengeId, code: code),
          );
    });
    if (state.hasError) {
      throw state.error!;
    }
  }

  Future<void> signOut() async {
    await ref.read(signOutUseCaseProvider).execute();
    state = const AsyncData(null);
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, Session?>(AuthController.new);
