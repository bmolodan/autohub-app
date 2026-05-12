import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radii.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Visual showcase of the AutoHub design system.
///
/// Drop it into `home:` in MaterialApp to verify tokens render correctly.
/// Once verified, delete this file or keep it as `/dev/showcase` route.
class ThemeShowcase extends StatelessWidget {
  const ThemeShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AutoHub · Design Tokens'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // ─── Typography ──────────────────────────────────────────
          const _SectionTitle('ТИПОГРАФІКА'),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Display large 32', style: AppTypography.displayLarge),
                const SizedBox(height: AppSpacing.sm),
                Text('Headline medium 22', style: AppTypography.headlineMedium),
                const SizedBox(height: AppSpacing.sm),
                Text('Title large 16', style: AppTypography.titleLarge),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Body large 14 — основний текст для описів та довгих абзаців у '
                  'застосунку, висота 1.5.',
                  style: AppTypography.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'У РОБОТІ',
                  style: AppTypography.overline.copyWith(
                    color: AppColors.brandBlack,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // ─── Colors ──────────────────────────────────────────────
          const _SectionTitle('КОЛЬОРИ'),
          const Row(
            children: [
              _ColorSwatch(color: AppColors.brandYellow, label: 'Yellow'),
              SizedBox(width: AppSpacing.sm),
              _ColorSwatch(color: AppColors.brandBlack, label: 'Black'),
              SizedBox(width: AppSpacing.sm),
              _ColorSwatch(color: AppColors.background, label: 'Cream'),
              SizedBox(width: AppSpacing.sm),
              _ColorSwatch(color: AppColors.error, label: 'Error'),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // ─── Buttons ─────────────────────────────────────────────
          const _SectionTitle('КНОПКИ'),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Primary CTA · Записатись'),
          ),
          const SizedBox(height: AppSpacing.sm),
          FilledButton(
            onPressed: () {},
            child: const Text('Secondary · Підтвердити'),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            onPressed: () {},
            child: const Text('Outlined · Скасувати'),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: () {},
            child: const Text('Текстова дія'),
          ),

          const SizedBox(height: AppSpacing.xl),

          // ─── Inputs ──────────────────────────────────────────────
          const _SectionTitle('ПОЛЯ ВВЕДЕННЯ'),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Номер телефону',
              hintText: '+380 ...',
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // ─── Chips ───────────────────────────────────────────────
          const _SectionTitle('ЧІПИ'),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              ChoiceChip(
                label: const Text('11:00'),
                selected: true,
                onSelected: (_) {},
              ),
              ChoiceChip(
                label: const Text('13:30'),
                selected: false,
                onSelected: (_) {},
              ),
              ChoiceChip(
                label: const Text('15:00'),
                selected: false,
                onSelected: (_) {},
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // ─── Switches ────────────────────────────────────────────
          const _SectionTitle('ПЕРЕМИКАЧІ'),
          const _Card(
            child: Column(
              children: [
                _SwitchRow(label: 'Зміна статусу замовлення', value: true),
                Divider(),
                _SwitchRow(label: 'Нагадування про ТО', value: true),
                Divider(),
                _SwitchRow(label: 'Акції та новини', value: false),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Text(text, style: AppTypography.overline),
      );
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.lgAll,
        ),
        child: child,
      );
}

class _ColorSwatch extends StatelessWidget {
  final Color color;
  final String label;
  const _ColorSwatch({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.mdAll,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 36,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: AppRadii.smAll,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(label, style: AppTypography.titleSmall),
            ],
          ),
        ),
      );
}

class _SwitchRow extends StatefulWidget {
  final String label;
  final bool value;
  const _SwitchRow({required this.label, required this.value});

  @override
  State<_SwitchRow> createState() => _SwitchRowState();
}

class _SwitchRowState extends State<_SwitchRow> {
  late bool _v = widget.value;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Text(widget.label, style: AppTypography.titleMedium),
          ),
          Switch(
            value: _v,
            onChanged: (next) => setState(() => _v = next),
          ),
        ],
      );
}
