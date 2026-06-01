import 'package:autohub/features/auth/domain/session.dart';
import 'package:autohub/features/cars/domain/vehicle.dart';
import 'package:autohub/features/orders/domain/active_order.dart';
import 'package:autohub/features/profile/application/use_cases/wipe_account.dart';
import 'package:autohub/features/profile/domain/client_profile.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../_helpers/fakes.dart';

void main() {
  group('WipeAccountUseCase', () {
    test('removes session, profile, vehicles, orders + photo files', () async {
      final orders = FakeActiveOrderRepository(seed: [
        ActiveOrder(
          id: 'o1',
          title: 'X',
          status: ActiveOrderStatus.pendingConfirmation,
          vehicleMake: 'Toyota',
          vehicleModel: 'Camry',
          vehiclePlate: 'AA 1234 BB',
          progress: null,
          eta: null,
          scheduledFor: DateTime.utc(2026, 5, 14),
          totalUah: 0,
          photos: [
            OrderPhoto(localPath: '/tmp/a.jpg', takenAt: DateTime.utc(2026)),
            OrderPhoto(localPath: '/tmp/b.jpg', takenAt: DateTime.utc(2026)),
          ],
        ),
      ]);
      final vehicles = FakeVehicleRepository(seed: const [
        Vehicle(
          id: 'v1',
          make: 'Toyota',
          model: 'Camry',
          year: 2018,
          plate: 'AA 1234 BB',
          vin: null,
          mileageKm: 0,
          nextServiceMileageKm: null,
        ),
      ]);
      final profile = FakeClientProfileRepository(
        seed: const ClientProfile(
          phone: '+380671234567',
          name: 'Bohdan',
        ),
      );
      final session = FakeSessionStorage(
        seed: Session(
          phone: '+380671234567',
          accessToken: 'fake-access',
          refreshToken: 'fake-refresh',
          accessExpiresAt: DateTime.utc(2026, 5, 13, 0, 15),
          createdAt: DateTime.utc(2026, 5, 13),
        ),
      );
      final photos = FakePhotoStorage();

      await WipeAccountUseCase(
        orders: orders,
        vehicles: vehicles,
        profile: profile,
        session: session,
        photos: photos,
      ).execute();

      expect(await orders.findAll(), isEmpty);
      expect(await vehicles.findAll(), isEmpty);
      expect(await profile.findByPhone('+380671234567'), isNull);
      expect(await session.read(), isNull);
      expect(photos.removeCalls, 2);
    });

    test('completes even when no orders / no photos exist', () async {
      final orders = FakeActiveOrderRepository();
      final vehicles = FakeVehicleRepository();
      final profile = FakeClientProfileRepository();
      final session = FakeSessionStorage();
      final photos = FakePhotoStorage();

      await WipeAccountUseCase(
        orders: orders,
        vehicles: vehicles,
        profile: profile,
        session: session,
        photos: photos,
      ).execute();

      expect(photos.removeCalls, 0);
    });
  });
}
