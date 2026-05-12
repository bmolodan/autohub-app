import 'package:flutter/material.dart';

/// Corner radii used across the AutoHub app.
///
/// Design language is built on rounded forms — pills for CTAs,
/// large rounded cards. No sharp angles.
class AppRadii {
  AppRadii._();

  /// Used inside compact UI (badges, micro-pills).
  static const double xs = 8.0;

  /// Small surfaces (chips, list rows).
  static const double sm = 12.0;

  /// Default cards, inputs.
  static const double md = 16.0;

  /// Default for content cards.
  static const double lg = 18.0;

  /// Hero cards, photo containers.
  static const double xl = 22.0;

  /// Phone-frame style outer wrappers, large hero blocks.
  static const double xxl = 32.0;

  /// Pill (full pill / capsule).
  static const double pill = 999.0;

  // ─── Pre-built BorderRadius shortcuts ──────────────────────────────
  static const BorderRadius xsAll = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius xxlAll = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));
}
