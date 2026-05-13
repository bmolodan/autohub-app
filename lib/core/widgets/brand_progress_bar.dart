import 'package:flutter/material.dart';

import '../theme/app_radii.dart';
import '../theme/brand_colors.dart';

/// Pill-clipped progress bar in brand yellow on a faint `borderStrong`
/// track. Used inside dark hero cards (in-progress order, OrderDetail).
class BrandProgressBar extends StatelessWidget {
  const BrandProgressBar({
    super.key,
    required this.value,
    this.minHeight = 6,
  });

  /// 0.0–1.0
  final double value;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ClipRRect(
      borderRadius: AppRadii.xsAll,
      child: LinearProgressIndicator(
        value: value,
        minHeight: minHeight,
        backgroundColor: c.borderStrong.withValues(alpha: 0.4),
        valueColor: AlwaysStoppedAnimation(c.brandYellow),
      ),
    );
  }
}
