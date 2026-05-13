import 'package:flutter/material.dart';

/// One service offered by the STO.
class ServiceCatalogItem {
  const ServiceCatalogItem({
    required this.id,
    required this.durationMinutes,
    required this.priceFromUah,
    required this.icon,
  });

  final String id;
  final int durationMinutes;
  final int priceFromUah;
  final IconData icon;
}

const serviceCatalog = <ServiceCatalogItem>[
  ServiceCatalogItem(
    id: 'oil_change',
    durationMinutes: 30,
    priceFromUah: 1600,
    icon: Icons.local_gas_station_outlined,
  ),
  ServiceCatalogItem(
    id: 'tires',
    durationMinutes: 45,
    priceFromUah: 1200,
    icon: Icons.tire_repair_outlined,
  ),
  ServiceCatalogItem(
    id: 'diagnostics',
    durationMinutes: 60,
    priceFromUah: 1800,
    icon: Icons.settings_outlined,
  ),
  ServiceCatalogItem(
    id: 'brakes',
    durationMinutes: 90,
    priceFromUah: 1850,
    icon: Icons.disc_full_outlined,
  ),
  ServiceCatalogItem(
    id: 'ac',
    durationMinutes: 60,
    priceFromUah: 1600,
    icon: Icons.ac_unit_outlined,
  ),
];
