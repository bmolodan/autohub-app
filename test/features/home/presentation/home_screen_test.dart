import 'package:autohub/features/home/presentation/home_screen.dart';
import 'package:autohub/features/orders/composition/orders_providers.dart';
import 'package:autohub/features/orders/domain/active_order.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../../../_helpers/fakes.dart';
import '../../../_helpers/test_app.dart';

Override _repo(List<ActiveOrder> orders) => activeOrderRepositoryProvider
    .overrideWithValue(FakeActiveOrderRepository(seed: orders));

ActiveOrder _inProgress() => ActiveOrder(
      id: 'a',
      title: 'Заміна колодок',
      status: ActiveOrderStatus.inProgress,
      vehicleMake: 'Toyota',
      vehicleModel: 'Camry',
      vehiclePlate: 'AA 1234 BC',
      progress: 0.6,
      eta: DateTime.utc(2026, 5, 13, 11),
      scheduledFor: null,
      totalUah: 2850,
    );

ActiveOrder _canceled() => const ActiveOrder(
      id: 'c',
      title: 'Шиномонтаж',
      status: ActiveOrderStatus.canceled,
      vehicleMake: 'Toyota',
      vehicleModel: 'Camry',
      vehiclePlate: 'AA 1234 BC',
      progress: null,
      eta: null,
      scheduledFor: null,
      totalUah: 1200,
    );

void main() {
  group('HomeScreen', () {
    testWidgets('renders EmptyState when no orders', (tester) async {
      await pumpScreen(
        tester,
        child: const HomeScreen(),
        overrides: [_repo([])],
      );
      await tester.pumpAndSettle();

      expect(find.text('Поки тиша'), findsOneWidget);
      expect(find.text('+ Записатись на СТО'), findsOneWidget);
    });

    testWidgets('renders in-progress + canceled cards', (tester) async {
      await pumpScreen(
        tester,
        child: const HomeScreen(),
        overrides: [
          _repo([_inProgress(), _canceled()])
        ],
      );
      await tester.pumpAndSettle();

      expect(find.text('У РЕМОНТІ'), findsOneWidget);
      expect(find.text('Заміна колодок'), findsOneWidget);
      expect(find.text('Шиномонтаж'), findsOneWidget);
      expect(find.text('Скасовано'), findsOneWidget);
    });

    testWidgets('greeting + "Записатись" CTA always present', (tester) async {
      await pumpScreen(
        tester,
        child: const HomeScreen(),
        overrides: [_repo([])],
      );
      await tester.pumpAndSettle();

      expect(find.text('Богдане'), findsOneWidget);
      expect(find.text('+ Записатись'), findsOneWidget);
    });
  });
}
