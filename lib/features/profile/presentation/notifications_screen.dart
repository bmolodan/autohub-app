import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/l10n_extension.dart';

/// Mockup 15 — notification preferences (UI-only stub).
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _statusUpdate = true;
  bool _serviceReminder = true;
  bool _masterMessage = true;
  bool _promotions = false;
  bool _quietHours = true;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(l.profileNotifications, style: AppTypography.titleLarge),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          children: [
            Text(l.notificationsHeading, style: AppTypography.headlineSmall),
            const SizedBox(height: AppSpacing.md),
            _ToggleTile(
              title: l.notifyStatusTitle,
              subtitle: l.notifyStatusSubtitle,
              value: _statusUpdate,
              onChanged: (v) => setState(() => _statusUpdate = v),
            ),
            _ToggleTile(
              title: l.notifyTOTitle,
              subtitle: l.notifyTOSubtitle,
              value: _serviceReminder,
              onChanged: (v) => setState(() => _serviceReminder = v),
            ),
            _ToggleTile(
              title: l.notifyMasterTitle,
              subtitle: l.notifyMasterSubtitle,
              value: _masterMessage,
              onChanged: (v) => setState(() => _masterMessage = v),
            ),
            _ToggleTile(
              title: l.notifyPromosTitle,
              subtitle: l.notifyPromosSubtitle,
              value: _promotions,
              onChanged: (v) => setState(() => _promotions = v),
            ),
            const SizedBox(height: AppSpacing.lg),
            _ToggleTile(
              title: l.notifyQuietTitle,
              subtitle: l.notifyQuietSubtitle,
              value: _quietHours,
              onChanged: (v) => setState(() => _quietHours = v),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.titleSmall),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
