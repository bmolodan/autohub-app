import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../application/ports/outbound/car_catalog_port.dart';
import '../../data/car_catalog.dart';

class AssetCarCatalog implements CarCatalogPort {
  const AssetCarCatalog({this.assetPath = 'assets/data/car_catalog.json'});

  final String assetPath;

  @override
  Future<CarCatalog> load() async {
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return CarCatalog(decoded.map(
      (k, v) => MapEntry(k, (v as List).cast<String>()),
    ));
  }
}
