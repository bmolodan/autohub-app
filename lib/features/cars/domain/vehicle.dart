/// Vehicle owned by a customer. Pure domain — no Flutter/infra deps.
class Vehicle {
  const Vehicle({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.plate,
    required this.vin,
    required this.mileageKm,
    required this.nextServiceMileageKm,
  });

  final String id;
  final String make;
  final String model;
  final int year;
  final String plate;
  final String? vin;
  final int mileageKm;
  final int? nextServiceMileageKm;

  @override
  bool operator ==(Object other) => other is Vehicle && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
