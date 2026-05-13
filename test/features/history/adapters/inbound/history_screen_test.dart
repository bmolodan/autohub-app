import 'package:autohub/features/history/adapters/inbound/history_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../_helpers/test_app.dart';

void main() {
  group('HistoryScreen', () {
    testWidgets('renders title + seeded mock history rows', (tester) async {
      await pumpScreen(tester, child: const HistoryScreen());
      await tester.pumpAndSettle();

      expect(find.text('Історія'), findsOneWidget);
      // The mock history asset seeds totals + month headings; assert at
      // least one ₴ amount renders.
      expect(find.textContaining('₴'), findsWidgets);
    });
  });
}
