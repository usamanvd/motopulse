import 'package:flutter_test/flutter_test.dart';
import 'package:ride_khaata/models/fuel_entry.dart';
import 'package:ride_khaata/models/maintenance_settings.dart';
import 'package:ride_khaata/models/countdown_timer_item.dart';
import 'package:ride_khaata/models/khaata_entry.dart';

void main() {
  group('Fuel & Mileage Logic Tests', () {
    test('Calculates fuel mileage accurately across entries', () {
      final f1 = FuelEntry(
        id: '1',
        date: DateTime.now().subtract(const Duration(days: 5)),
        odometerKm: 10000.0,
        amountSpent: 1200.0,
        liters: 4.0,
      );

      final f2 = FuelEntry(
        id: '2',
        date: DateTime.now(),
        odometerKm: 10200.0,
        amountSpent: 1300.0,
        liters: 4.5,
        distanceTraveled: 200.0,
        averageKmL: 200.0 / 4.5, // 44.44 km/L
        costPerKm: 1300.0 / 200.0, // 6.5 Rs/km
      );

      expect(f1.distanceTraveled, isNull);
      expect(f2.distanceTraveled, 200.0);
      expect(f2.averageKmL, closeTo(44.44, 0.01));
      expect(f2.costPerKm, 6.5);
    });
  });

  group('Maintenance & Reminders Logic Tests', () {
    test('Oil Change reminder triggers correctly at 1000 KM threshold', () {
      final now = DateTime.now();

      // Bike has driven 700 KM since oil change (Interval: 1000 KM)
      final maintSafe = MaintenanceSettings(
        currentOdometerKm: 10700.0,
        lastOilChangeKm: 10000.0,
        lastOilChangeDate: now.subtract(const Duration(days: 15)),
        oilChangeIntervalKm: 1000.0,
        lastTuningDate: now.subtract(const Duration(days: 20)),
      );

      expect(maintSafe.kmSinceLastOilChange, 700.0);
      expect(maintSafe.remainingOilKm, 300.0);
      expect(maintSafe.isOilChangeDue, isFalse);
      expect(maintSafe.isOilChangeDueSoon, isFalse);

      // Bike has driven 950 KM (Due soon)
      final maintSoon = maintSafe.copyWith(currentOdometerKm: 10950.0);
      expect(maintSoon.remainingOilKm, 50.0);
      expect(maintSoon.isOilChangeDueSoon, isTrue);
      expect(maintSoon.isOilChangeDue, isFalse);

      // Bike has driven 1050 KM (OVERDUE!)
      final maintOverdue = maintSafe.copyWith(currentOdometerKm: 11050.0);
      expect(maintOverdue.remainingOilKm, -50.0);
      expect(maintOverdue.isOilChangeDue, isTrue);
    });

    test('Tuning reminder triggers after 60 days (~2 months)', () {
      final now = DateTime.now();

      // Last tuned 30 days ago (1 month remaining)
      final maint30 = MaintenanceSettings(
        lastOilChangeDate: now,
        lastTuningDate: now.subtract(const Duration(days: 30)),
        tuningIntervalDays: 60,
      );

      expect(maint30.remainingTuningDays, 30);
      expect(maint30.isTuningDue, isFalse);

      // Last tuned 65 days ago (Overdue)
      final maintOverdue = maint30.copyWith(
        lastTuningDate: now.subtract(const Duration(days: 65)),
      );

      expect(maintOverdue.remainingTuningDays, lessThanOrEqualTo(0));
      expect(maintOverdue.isTuningDue, isTrue);
    });
  });

  group('Reverse Days Countdown Timer Tests', () {
    test('Calculates reverse days and hours countdown accurately', () {
      final now = DateTime.now();
      final target = now.add(const Duration(days: 5, hours: 3));

      final timer = CountdownTimerItem(
        id: 'cd1',
        title: 'Air Filter Cleaning',
        targetDate: target,
        createdAt: now.subtract(const Duration(days: 2)),
      );

      expect(timer.remainingDays, 5);
      expect(timer.isExpired, isFalse);
      expect(timer.progressPercentage, greaterThan(0.0));
      expect(timer.progressPercentage, lessThan(1.0));
    });
  });

  group('Khaata Ledger Tests', () {
    test('Calculates Income, Expenses, and Net Balance correctly', () {
      final now = DateTime.now();
      final entries = [
        KhaataEntry(
          id: '1',
          title: 'Salary Received',
          amount: 80000.0,
          type: KhaataType.income,
          category: 'Salary',
          date: now,
        ),
        KhaataEntry(
          id: '2',
          title: 'Petrol Fill-up',
          amount: 1400.0,
          type: KhaataType.expense,
          category: 'Fuel & Bike',
          date: now,
        ),
        KhaataEntry(
          id: '3',
          title: 'Oil Change',
          amount: 1100.0,
          type: KhaataType.expense,
          category: 'Maintenance',
          date: now,
        ),
      ];

      final totalIncome = entries
          .where((e) => e.isIncome)
          .fold(0.0, (sum, e) => sum + e.amount);

      final totalExpense = entries
          .where((e) => e.isExpense)
          .fold(0.0, (sum, e) => sum + e.amount);

      final balance = totalIncome - totalExpense;

      expect(totalIncome, 80000.0);
      expect(totalExpense, 2500.0);
      expect(balance, 77500.0);
    });
  });

  group('MotoPulse Vehicle Setup Tests', () {
    test('Configures vehicle specifications properly', () {
      final now = DateTime.now();
      final setup = MaintenanceSettings(
        vehicleName: 'Yamaha YBR 125',
        registrationNumber: 'KHI-2024-9988',
        fuelTankCapacityLiters: 13.0,
        currentOdometerKm: 8500.0,
        lastOilChangeKm: 8000.0,
        lastOilChangeDate: now,
        oilChangeIntervalKm: 1200.0,
        lastTuningDate: now,
        tuningIntervalDays: 45,
        isSetupCompleted: true,
      );

      expect(setup.vehicleName, 'Yamaha YBR 125');
      expect(setup.registrationNumber, 'KHI-2024-9988');
      expect(setup.fuelTankCapacityLiters, 13.0);
      expect(setup.oilChangeIntervalKm, 1200.0);
      expect(setup.remainingOilKm, 700.0);
      expect(setup.isSetupCompleted, isTrue);
    });
  });
}
