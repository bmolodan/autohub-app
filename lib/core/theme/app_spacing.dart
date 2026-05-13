/// Spacing scale.
///
/// Use these instead of magic numbers for `Padding`, `SizedBox`, gaps in `Row`/`Column`.
class AppSpacing {
  AppSpacing._();

  static const double xxs = 4.0;
  static const double xs = 6.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;

  /// Semantic component-padding tokens.
  /// Buttons (pill CTAs) use [btnH] × [btnV]; form fields and chips use
  /// their named pair. Keeps `AppTheme` and ad-hoc widgets from drifting.
  static const double btnH = 20.0; // = xl
  static const double btnV = 14.0;
  static const double inputH = 14.0;
  static const double inputV = 14.0;
  static const double chipH = 14.0;
  static const double chipV = 8.0; // = sm

  /// Max content width for tablet / large screens. Phone-first design;
  /// this clamps the main shell so layouts don't stretch on iPad.
  static const double contentMaxWidth = 480.0;
}
