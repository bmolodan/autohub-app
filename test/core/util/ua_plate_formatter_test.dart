import 'package:autohub/core/util/ua_plate_formatter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

TextEditingValue _format(String input) {
  return const UaPlateInputFormatter().formatEditUpdate(
    TextEditingValue.empty,
    TextEditingValue(text: input),
  );
}

void main() {
  group('UaPlateInputFormatter', () {
    test('uppercases lower-case input and inserts spaces', () {
      expect(_format('aa1234bb').text, 'AA 1234 BB');
    });

    test('normalizes Cyrillic look-alikes to Latin', () {
      // А, В, Е are Cyrillic capitals; map to Latin A, B, E.
      expect(_format('АА1234ВВ').text, 'AA 1234 BB');
      expect(_format('Не1234ое').text.startsWith('HE 1234'), isTrue);
    });

    test('drops disallowed letters (Y, Z, F, ...)', () {
      // Z, Y, F are not in the 12 allowed plate letters; they get stripped
      // and the remaining valid characters keep flowing.
      expect(_format('AZ1234BY').text, 'A1 234B');
    });

    test('caps at 8 characters + 2 spaces total', () {
      expect(_format('AA1234BBCC').text, 'AA 1234 BB');
    });

    test('partial input is partial — only formats what is there', () {
      expect(_format('AA12').text, 'AA 12');
      expect(_format('AA').text, 'AA');
      expect(_format('').text, '');
    });

    test('cursor always at the end after format', () {
      final v = _format('aa1234bb');
      expect(v.selection, TextSelection.collapsed(offset: v.text.length));
    });
  });

  group('validateUaPlate', () {
    test('null/empty returns the required message', () {
      expect(
        validateUaPlate(null, requiredMessage: 'req', invalidMessage: 'inv'),
        'req',
      );
      expect(
        validateUaPlate('', requiredMessage: 'req', invalidMessage: 'inv'),
        'req',
      );
      expect(
        validateUaPlate('   ', requiredMessage: 'req', invalidMessage: 'inv'),
        'req',
      );
    });

    test('correctly-formatted plate passes', () {
      expect(
        validateUaPlate('AA 1234 BB',
            requiredMessage: 'req', invalidMessage: 'inv'),
        isNull,
      );
    });

    test('wrong-length plate returns invalid', () {
      expect(
        validateUaPlate('AA 123 BB',
            requiredMessage: 'req', invalidMessage: 'inv'),
        'inv',
      );
      expect(
        validateUaPlate('A 1234 BB',
            requiredMessage: 'req', invalidMessage: 'inv'),
        'inv',
      );
    });

    test('disallowed letter returns invalid', () {
      // Z not in allowed set.
      expect(
        validateUaPlate('AZ 1234 BB',
            requiredMessage: 'req', invalidMessage: 'inv'),
        'inv',
      );
    });

    test('missing spaces (raw 8 chars) returns invalid', () {
      expect(
        validateUaPlate('AA1234BB',
            requiredMessage: 'req', invalidMessage: 'inv'),
        'inv',
      );
    });
  });
}
