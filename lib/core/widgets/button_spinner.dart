import 'package:flutter/material.dart';

import '../theme/app_sizes.dart';

/// Loading spinner sized to fit inside a button's child slot. Use in place
/// of an inline `SizedBox(width: 20, height: 20, child:
/// CircularProgressIndicator(strokeWidth: 2))` so all submit-button
/// loading states stay consistent.
class ButtonSpinner extends StatelessWidget {
  const ButtonSpinner({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: AppIconSize.md,
      height: AppIconSize.md,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }
}
