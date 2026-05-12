import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'empty_state.dart';
import 'error_state.dart';

/// Dev-only: side-by-side preview of empty + error states.
class StatesShowcase extends StatelessWidget {
  const StatesShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('States (dev)', style: AppTypography.titleMedium),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Empty'),
              Tab(text: 'Error'),
            ],
          ),
        ),
        body: const SafeArea(
          child: TabBarView(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: EmptyState(
                  icon: Icons.car_repair_outlined,
                  title: 'Поки тиша',
                  subtitle:
                      'Активних замовлень немає. Запишіться на сервіс — ми про все подбаємо.',
                  ctaLabel: '+ Записатись на СТО',
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: ErrorState(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
