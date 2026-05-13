import 'package:autohub/features/orders/adapters/inbound/order_detail_screen.dart';
import 'package:autohub/features/orders/composition/orders_providers.dart';
import 'package:autohub/features/orders/domain/active_order.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../../../../_helpers/fakes.dart';
import '../../../../_helpers/test_app.dart';

ActiveOrder _inProgress() => ActiveOrder(
      id: 'o-ip',
      title: 'Заміна гальмівних колодок',
      status: ActiveOrderStatus.inProgress,
      vehicleMake: 'Toyota',
      vehicleModel: 'Camry',
      vehiclePlate: 'AA 1234 BC',
      progress: 0.6,
      eta: DateTime.utc(2026, 5, 13, 11, 0),
      scheduledFor: null,
      totalUah: 2850,
      timeline: [
        OrderTimelineEntry(
          stage: OrderStage.accepted,
          at: DateTime.utc(2026, 5, 13, 7),
        ),
        OrderTimelineEntry(
          stage: OrderStage.inProgress,
          at: DateTime.utc(2026, 5, 13, 9),
        ),
      ],
    );

ActiveOrder _pending() => ActiveOrder(
      id: 'o-pn',
      title: 'Діагностика двигуна',
      status: ActiveOrderStatus.pendingConfirmation,
      vehicleMake: 'Toyota',
      vehicleModel: 'Camry',
      vehiclePlate: 'AA 1234 BC',
      progress: null,
      eta: null,
      scheduledFor: DateTime.utc(2026, 5, 14, 16),
      totalUah: 1800,
    );

ActiveOrder _canceled() => ActiveOrder(
      id: 'o-cn',
      title: 'Шиномонтаж',
      status: ActiveOrderStatus.canceled,
      vehicleMake: 'Toyota',
      vehicleModel: 'Camry',
      vehiclePlate: 'AA 1234 BC',
      progress: null,
      eta: null,
      scheduledFor: null,
      totalUah: 1200,
      timeline: [
        OrderTimelineEntry(
          stage: OrderStage.canceled,
          at: DateTime.utc(2026, 5, 13, 12),
        ),
      ],
    );

Override _repo(ActiveOrder o) => activeOrderRepositoryProvider
    .overrideWithValue(FakeActiveOrderRepository(seed: [o]));

void main() {
  group('OrderDetailScreen', () {
    testWidgets('renders the in-progress hero with progress + ETA',
        (tester) async {
      final order = _inProgress();
      await pumpScreen(
        tester,
        child: OrderDetailScreen(orderId: order.id),
        overrides: [_repo(order)],
      );
      await tester.pumpAndSettle();

      expect(find.text('У РЕМОНТІ'), findsOneWidget);
      expect(find.text('Заміна гальмівних колодок'), findsOneWidget);
      expect(find.text('ХІД РОБОТИ'), findsOneWidget);
      expect(find.text('Прийнято'), findsOneWidget);
      expect(find.text('У ремонті'), findsOneWidget);
    });

    testWidgets('renders the pending hero with cancel button', (tester) async {
      final order = _pending();
      await pumpScreen(
        tester,
        child: OrderDetailScreen(orderId: order.id),
        overrides: [_repo(order)],
      );
      await tester.pumpAndSettle();

      expect(find.text('ОЧІКУЄ ПІДТВЕРДЖЕННЯ'), findsOneWidget);
      expect(find.text('Діагностика двигуна'), findsOneWidget);
      expect(find.text('Скасувати запис'), findsOneWidget);
    });

    testWidgets('renders the canceled body without cancel button',
        (tester) async {
      final order = _canceled();
      await pumpScreen(
        tester,
        child: OrderDetailScreen(orderId: order.id),
        overrides: [_repo(order)],
      );
      await tester.pumpAndSettle();

      expect(find.text('СКАСОВАНО'), findsOneWidget);
      expect(find.text('Шиномонтаж'), findsOneWidget);
      expect(find.text('Скасувати запис'), findsNothing);
    });

    testWidgets('"Скасувати запис" shows confirm dialog with No + Yes',
        (tester) async {
      final order = _pending();
      await pumpScreen(
        tester,
        child: OrderDetailScreen(orderId: order.id),
        overrides: [_repo(order)],
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Скасувати запис'));
      await tester.pumpAndSettle();

      expect(find.text('Скасувати запис?'), findsOneWidget);
      expect(find.text('Ні'), findsOneWidget);
      expect(find.text('Так, скасувати'), findsOneWidget);

      await tester.tap(find.text('Ні'));
      await tester.pumpAndSettle();
      expect(find.text('Скасувати запис?'), findsNothing);
    });

    testWidgets('shows "Замовлення не знайдено" when order is missing',
        (tester) async {
      await pumpScreen(
        tester,
        child: const OrderDetailScreen(orderId: 'missing'),
        overrides: [
          activeOrderRepositoryProvider
              .overrideWithValue(FakeActiveOrderRepository()),
        ],
      );
      await tester.pumpAndSettle();

      expect(find.text('Замовлення не знайдено'), findsOneWidget);
    });
  });
}
