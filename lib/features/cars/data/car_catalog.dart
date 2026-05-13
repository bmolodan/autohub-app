/// Bundled catalog of car makes and their models. Keys are make names, values
/// are the list of models. Built once at app start from `assets/data/car_catalog.json`.
class CarCatalog {
  const CarCatalog(this._makesToModels);

  final Map<String, List<String>> _makesToModels;

  /// All makes, sorted alphabetically.
  List<String> get makes => _makesToModels.keys.toList()..sort();

  /// Models for a given make, or an empty list if the make is unknown.
  List<String> modelsFor(String make) => _makesToModels[make] ?? const [];

  bool hasMake(String make) => _makesToModels.containsKey(make);
  bool hasModel(String make, String model) => modelsFor(make).contains(model);
}
