import 'dart:convert';

class MaintenanceSettings {
  final String vehicleName;
  final String registrationNumber;
  final double currentOdometerKm;
  final double fuelTankCapacityLiters;
  final double lastOilChangeKm;
  final DateTime lastOilChangeDate;
  final double oilChangeIntervalKm; // e.g. 1000 km
  final DateTime lastTuningDate;
  final int tuningIntervalDays; // default 60 days (2 months)
  final bool isSetupCompleted;

  MaintenanceSettings({
    this.vehicleName = 'Honda CG 125',
    this.registrationNumber = '',
    this.currentOdometerKm = 12450.0,
    this.fuelTankCapacityLiters = 9.2,
    this.lastOilChangeKm = 11800.0,
    required this.lastOilChangeDate,
    this.oilChangeIntervalKm = 1000.0,
    required this.lastTuningDate,
    this.tuningIntervalDays = 60, // 2 months
    this.isSetupCompleted = false,
  });

  // Calculate remaining km for oil change
  double get kmSinceLastOilChange => (currentOdometerKm - lastOilChangeKm).clamp(0, double.infinity);
  double get remainingOilKm => oilChangeIntervalKm - kmSinceLastOilChange;
  bool get isOilChangeDue => remainingOilKm <= 0;
  bool get isOilChangeDueSoon => remainingOilKm > 0 && remainingOilKm <= 150;

  // Calculate days for tuning
  DateTime get nextTuningDate => lastTuningDate.add(Duration(days: tuningIntervalDays));
  int get remainingTuningDays {
    final now = DateTime.now();
    return nextTuningDate.difference(now).inDays;
  }
  bool get isTuningDue => remainingTuningDays <= 0;
  bool get isTuningDueSoon => remainingTuningDays > 0 && remainingTuningDays <= 7;

  MaintenanceSettings copyWith({
    String? vehicleName,
    String? registrationNumber,
    double? currentOdometerKm,
    double? fuelTankCapacityLiters,
    double? lastOilChangeKm,
    DateTime? lastOilChangeDate,
    double? oilChangeIntervalKm,
    DateTime? lastTuningDate,
    int? tuningIntervalDays,
    bool? isSetupCompleted,
  }) {
    return MaintenanceSettings(
      vehicleName: vehicleName ?? this.vehicleName,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      currentOdometerKm: currentOdometerKm ?? this.currentOdometerKm,
      fuelTankCapacityLiters: fuelTankCapacityLiters ?? this.fuelTankCapacityLiters,
      lastOilChangeKm: lastOilChangeKm ?? this.lastOilChangeKm,
      lastOilChangeDate: lastOilChangeDate ?? this.lastOilChangeDate,
      oilChangeIntervalKm: oilChangeIntervalKm ?? this.oilChangeIntervalKm,
      lastTuningDate: lastTuningDate ?? this.lastTuningDate,
      tuningIntervalDays: tuningIntervalDays ?? this.tuningIntervalDays,
      isSetupCompleted: isSetupCompleted ?? this.isSetupCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vehicleName': vehicleName,
      'registrationNumber': registrationNumber,
      'currentOdometerKm': currentOdometerKm,
      'fuelTankCapacityLiters': fuelTankCapacityLiters,
      'lastOilChangeKm': lastOilChangeKm,
      'lastOilChangeDate': lastOilChangeDate.toIso8601String(),
      'oilChangeIntervalKm': oilChangeIntervalKm,
      'lastTuningDate': lastTuningDate.toIso8601String(),
      'tuningIntervalDays': tuningIntervalDays,
      'isSetupCompleted': isSetupCompleted,
    };
  }

  factory MaintenanceSettings.fromMap(Map<String, dynamic> map) {
    return MaintenanceSettings(
      vehicleName: (map['vehicleName'] as String?) ?? 'Honda CG 125',
      registrationNumber: (map['registrationNumber'] as String?) ?? '',
      currentOdometerKm: (map['currentOdometerKm'] as num?)?.toDouble() ?? 12450.0,
      fuelTankCapacityLiters: (map['fuelTankCapacityLiters'] as num?)?.toDouble() ?? 9.2,
      lastOilChangeKm: (map['lastOilChangeKm'] as num?)?.toDouble() ?? 11800.0,
      lastOilChangeDate: map['lastOilChangeDate'] != null
          ? DateTime.parse(map['lastOilChangeDate'] as String)
          : DateTime.now().subtract(const Duration(days: 20)),
      oilChangeIntervalKm: (map['oilChangeIntervalKm'] as num?)?.toDouble() ?? 1000.0,
      lastTuningDate: map['lastTuningDate'] != null
          ? DateTime.parse(map['lastTuningDate'] as String)
          : DateTime.now().subtract(const Duration(days: 42)),
      tuningIntervalDays: (map['tuningIntervalDays'] as num?)?.toInt() ?? 60,
      isSetupCompleted: (map['isSetupCompleted'] as bool?) ?? false,
    );
  }

  String toJson() => json.encode(toMap());
  factory MaintenanceSettings.fromJson(String source) =>
      MaintenanceSettings.fromMap(json.decode(source) as Map<String, dynamic>);
}
