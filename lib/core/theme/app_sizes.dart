/// Named pixel sizes for icons and small containers.
///
/// Reach for these instead of raw numbers when sizing an [Icon] or a
/// fixed-dimension `Container` (e.g. avatar, icon bubble).
class AppIconSize {
  AppIconSize._();

  static const double sm = 18.0;
  static const double md = 20.0;
  static const double lg = 22.0;
  static const double xl = 24.0;
  static const double hero = 36.0;
}

class AppSizes {
  AppSizes._();

  /// Round avatar in headers and list rows.
  static const double avatar = 56.0;

  /// Large square-ish icon bubble (empty state, account-delete warning).
  static const double iconBubble = 72.0;

  /// OTP digit slot.
  static const double otpSlotHeight = 56.0;

  /// Primary CTA min height (pill buttons).
  static const double ctaMinHeight = 50.0;
}
