import 'dart:convert';

class FuelEntry {
  final String id;
  final DateTime date;
  final double odometerKm;
  final double amountSpent;
  final double liters;
  final String notes;
  final String fuelStation;

  // Computed properties compared to previous entry
  final double? distanceTraveled;
  final double? averageKmL;
  final double? costPerKm;

  FuelEntry({
    required this.id,
    required this.date,
    required this.odometerKm,
    required this.amountSpent,
    required this.liters,
    this.notes = '',
    this.fuelStation = '',
    this.distanceTraveled,
    this.averageKmL,
    this.costPerKm,
  });

  FuelEntry copyWith({
    String? id,
    DateTime? date,
    double? odometerKm,
    double? amountSpent,
    double? liters,
    String? notes,
    String? fuelStation,
    double? distanceTraveled,
    double? averageKmL,
    double? costPerKm,
  }) {
    return FuelEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      odometerKm: odometerKm ?? this.odometerKm,
      amountSpent: amountSpent ?? this.amountSpent,
      liters: liters ?? this.liters,
      notes: notes ?? this.notes,
      fuelStation: fuelStation ?? this.fuelStation,
      distanceTraveled: distanceTraveled ?? this.distanceTraveled,
      averageKmL: averageKmL ?? this.averageKmL,
      costPerKm: costPerKm ?? this.costPerKm,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'odometerKm': odometerKm,
      'amountSpent': amountSpent,
      'liters': liters,
      'notes': notes,
      'fuelStation': fuelStation,
    };
  }

  factory FuelEntry.fromMap(Map<String, dynamic> map) {
    return FuelEntry(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      odometerKm: (map['odometerKm'] as num).toDouble(),
      amountSpent: (map['amountSpent'] as num).toDouble(),
      liters: (map['liters'] as num).toDouble(),
      notes: (map['notes'] as String?) ?? '',
      fuelStation: (map['fuelStation'] as String?) ?? '',
    );
  }

  String toJson() => json.encode(toMap());
  factory FuelEntry.fromJson(String source) =>
      FuelEntry.fromMap(json.decode(source) as Map<String, dynamic>);
}
