import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/config/app_environment.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/util/clock.dart';
import '../../../core/util/id_generator.dart';
import '../../cars/composition/cars_providers.dart';
import '../../history/composition/history_providers.dart';
import '../../orders/composition/orders_providers.dart';
import '../../profile/composition/profile_providers.dart';
import '../adapters/outbound/fake_otp_gateway.dart';
import '../adapters/outbound/http_otp_gateway.dart';
import '../adapters/outbound/secure_storage_session_storage.dart';
import '../application/ports/outbound/otp_gateway_port.dart';
import '../application/ports/outbound/session_storage_port.dart';
import '../application/use_cases/request_otp.dart';
import '../application/use_cases/sign_out.dart';
import '../application/use_cases/verify_otp.dart';
import '../domain/session.dart';

/// Composition root for auth.
final otpGatewayProvider = Provider<OtpGatewayPort>((ref) {
  return switch (ref.watch(appEnvironmentProvider)) {
    AppEnvironment.remote => HttpOtpGateway(ref.watch(dioProvider)),
    AppEnvironment.local => FakeOtpGateway(
        clock: ref.watch(clockProvider),
        idGen: ref.watch(idGeneratorProvider),
      ),
  };
});

final secureStorageProvider = Provider<FlutterSecureStorage>((_) {
  return const FlutterSecureStorage();
});

final sessionStorageProvider = Provider<SessionStoragePort>(
  (ref) => SecureStorageSessionStorage(storage: ref.watch(secureStorageProvider)),
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
  (ref) => SignOutUseCase(
    ref.watch(otpGatewayProvider),
    ref.watch(sessionStorageProvider),
  ),
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
    // Drop cached data from any prior session — new JWT belongs to a
    // different customer; their orders/vehicles/profile must reload.
    _invalidateSessionScopedData();
  }

  Future<void> signOut() async {
    await ref.read(signOutUseCaseProvider).execute();
    state = const AsyncData(null);
    _invalidateSessionScopedData();
  }

  void _invalidateSessionScopedData() {
    ref.invalidate(ordersControllerProvider);
    ref.invalidate(vehiclesControllerProvider);
    ref.invalidate(clientProfileControllerProvider);
    ref.invalidate(aggregatedServiceHistoryProvider);
    // Family caches: every (vehicleId, orderId) entry the prior session
    // populated must also be cleared, otherwise direct navigation to a
    // detail screen will return the previous customer's data.
    ref.invalidate(vehicleByIdProvider);
    ref.invalidate(orderByIdProvider);
    ref.invalidate(serviceHistoryProvider);
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, Session?>(AuthController.new);
