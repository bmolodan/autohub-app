import 'package:flutter/services.dart';

/// Twelve Latin letters that overlap with Cyrillic glyphs and are permitted
/// on Ukrainian civil plates since 2004: A B C E H I K M O P T X.
const _plateLetters = 'ABCEHIKMOPTX';

/// Cyrillic look-alikes mapped to their Latin twin so the catalog stays
/// in one alphabet regardless of how the user typed.
const _cyrToLat = <String, String>{
  'А': 'A',
  'В': 'B',
  'С': 'C',
  'Е': 'E',
  'Н': 'H',
  'І': 'I',
  'К': 'K',
  'М': 'M',
  'О': 'O',
  'Р': 'P',
  'Т': 'T',
  'Х': 'X',
};

/// In-place input formatter for UA plates. Auto-uppercases, normalizes
/// Cyrillic look-alikes to Latin, drops disallowed characters, inserts
/// spaces at the right positions, and caps total length at 8 chars + 2
/// spaces.
class UaPlateInputFormatter extends TextInputFormatter {
  const UaPlateInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = RegExp(r'\d');
    final cleaned = <String>[];
    for (final raw in newValue.text.toUpperCase().split('')) {
      final c = _cyrToLat[raw] ?? raw;
      if (_plateLetters.contains(c) || digits.hasMatch(c)) {
        cleaned.add(c);
      }
      if (cleaned.length == 8) break;
    }

    final buf = StringBuffer();
    for (var i = 0; i < cleaned.length; i++) {
      if (i == 2 || i == 6) buf.write(' ');
      buf.write(cleaned[i]);
    }
    final text = buf.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

final RegExp _plateRegex =
    RegExp('^[$_plateLetters]{2} \\d{4} [$_plateLetters]{2}\$');

/// Validates the displayed (formatted) plate value. Use as a [TextFormField]
/// validator together with [UaPlateInputFormatter].
String? validateUaPlate(
  String? value, {
  required String requiredMessage,
  required String invalidMessage,
}) {
  if (value == null || value.trim().isEmpty) return requiredMessage;
  return _plateRegex.hasMatch(value) ? null : invalidMessage;
}
