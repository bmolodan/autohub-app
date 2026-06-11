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

ActiveOrder _inProgressFull() => ActiveOrder(
      id: 'o-ip-full',
      title: 'комп вакуумний',
      status: ActiveOrderStatus.inProgress,
      vehicleMake: 'Mitsubishi',
      vehicleModel: 'Pajero',
      vehiclePlate: 'JMBLYV98W8J403478',
      progress: 0.5,
      eta: DateTime.utc(2026, 6, 5, 9),
      scheduledFor: null,
      totalUah: 9940,
      paidUah: 0,
      discountUah: 160,
      number: 'A1966',
      orderType: 'Платний',
      resource: 'Підйомник 1',
      statusColor: '#099B49',
      dueDate: DateTime.utc(2026, 6, 5, 12, 13),
      isUrgent: false,
      isOverdue: true,
      items: const [
        OrderItem(
          id: '1',
          name: 'Комп. діагностика',
          quantity: 1,
          priceUah: 800,
          discountUah: 160,
          sumUah: 640,
          kind: OrderItemKind.service,
        ),
        OrderItem(
          id: '2',
          name: 'Очисник гальм BARDAHL',
          quantity: 2,
          priceUah: 250,
          discountUah: 0,
          sumUah: 500,
          kind: OrderItemKind.product,
        ),
      ],
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

    testWidgets(
        'in-progress: shows info row (type/place/due), КОШТОРИС section with grouped items + totals, and overdue chip',
        (tester) async {
      final order = _inProgressFull();
      await pumpScreen(
        tester,
        child: OrderDetailScreen(orderId: order.id),
        overrides: [_repo(order)],
      );
      await tester.pumpAndSettle();

      // Info row — at least one info field renders.
      expect(find.text('Тип робіт'), findsOneWidget);
      expect(find.text('Платний'), findsOneWidget);
      expect(find.text('Місце'), findsOneWidget);
      expect(find.text('Підйомник 1'), findsOneWidget);
      expect(find.text('Виконати до'), findsOneWidget);

      // Overdue chip on the hero
      expect(find.text('Прострочено'), findsOneWidget);

      // Estimate section + grouped items
      expect(find.text('КОШТОРИС'), findsOneWidget);
      expect(find.text('Послуги'), findsOneWidget);
      expect(find.text('Запчастини'), findsOneWidget);
      expect(find.text('Комп. діагностика'), findsOneWidget);
      expect(find.text('Очисник гальм BARDAHL'), findsOneWidget);

      // Totals row labels
      expect(find.text('Сума'), findsOneWidget);
      expect(find.text('Знижка'), findsOneWidget);
      expect(find.text('До сплати'), findsOneWidget);
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
