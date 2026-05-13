import 'package:autohub/features/onboarding/presentation/onboarding_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../_helpers/test_app.dart';

void main() {
  group('OnboardingScreen', () {
    testWidgets('renders the first step title + skip + next', (tester) async {
      await pumpScreen(tester, child: const OnboardingScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('Записуйтесь'), findsOneWidget);
      expect(find.text('Пропустити'), findsOneWidget);
      expect(find.text('Далі'), findsOneWidget);
    });
  });
}
