import '../../../l10n/generated/app_localizations.dart';

/// Localized title for a catalog id.
String serviceTitle(AppLocalizations l, String id) => switch (id) {
      'oil_change' => l.serviceOilChange,
      'tires' => l.serviceTires,
      'diagnostics' => l.serviceDiagnostics,
      'brakes' => l.serviceBrakes,
      'ac' => l.serviceAc,
      _ => id,
    };
