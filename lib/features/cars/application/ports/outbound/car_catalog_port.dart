import '../../../data/car_catalog.dart';

/// Outbound port — capability, not technology. The asset-bundled adapter
/// lives in `adapters/outbound/asset_car_catalog.dart`; future swap could
/// fetch the catalog from a server.
abstract interface class CarCatalogPort {
  Future<CarCatalog> load();
}
