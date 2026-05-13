import 'package:flutter/material.dart';

import '../../l10n/l10n_extension.dart';
import '../theme/app_colors.dart';

/// Shows a Material confirm dialog with localized No + destructive Confirm
/// buttons. Returns `true` when the user confirms, `false`/null otherwise.
///
/// Default destructive styling on Confirm matches the existing cancel-order
/// and delete-car dialogs. Pass `destructive: false` for non-destructive
/// confirmations (rare in this app).
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  bool destructive = true,
}) async {
  final l = context.l10n;
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(l.commonNo),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: destructive
              ? TextButton.styleFrom(foregroundColor: AppColors.error)
              : null,
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}
