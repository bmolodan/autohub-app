import 'package:autohub/features/cars/data/car_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

/// We can unit-test [CarCatalog] purely. The adapter that wraps rootBundle
/// is too thin to need its own test — if `rootBundle.loadString` works and
/// `jsonDecode` works, the adapter works.

void main() {
  group('CarCatalog', () {
    const catalog = CarCatalog({
      'Toyota': ['Camry', 'Corolla', 'Hilux'],
      'Audi': ['A3', 'A4'],
      'BMW': ['3 Series', '5 Series'],
    });

    test('makes returns keys sorted ascending', () {
      expect(catalog.makes, ['Audi', 'BMW', 'Toyota']);
    });

    test('modelsFor returns the list for a known make', () {
      expect(catalog.modelsFor('Toyota'), ['Camry', 'Corolla', 'Hilux']);
    });

    test('modelsFor returns empty list for an unknown make (no throw)', () {
      expect(catalog.modelsFor('Unknown'), isEmpty);
    });

    test('hasMake / hasModel boolean checks', () {
      expect(catalog.hasMake('Toyota'), isTrue);
      expect(catalog.hasMake('Lada'), isFalse);
      expect(catalog.hasModel('Toyota', 'Camry'), isTrue);
      expect(catalog.hasModel('Toyota', 'Lambo'), isFalse);
      expect(catalog.hasModel('Lada', 'anything'), isFalse);
    });
  });
}
