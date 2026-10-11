import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/fuel_entry.dart';
import '../models/maintenance_settings.dart';
import '../models/countdown_timer_item.dart';
import '../models/khaata_entry.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';
import '../services/sync_service.dart';

class AppProvider extends ChangeNotifier {
  final Uuid _uuid = const Uuid();

  // State collections
  List<FuelEntry> _fuelEntries = [];
  MaintenanceSettings _maintenance = MaintenanceSettings(
    lastOilChangeDate: DateTime.now().subtract(const Duration(days: 15)),
    lastTuningDate: DateTime.now().subtract(const Duration(days: 30)),
  );
  List<CountdownTimerItem> _countdowns = [];
  List<KhaataEntry> _khaataEntries = [];
  UserProfile _userProfile = UserProfile(
    id: 'guest_user',
    email: 'guest@ridekhaata.app',
    displayName: 'Bike Rider',
    isLoggedIn: false,
  );

  bool _isDarkMode = false;
  bool _isLoading = true;
  bool _isSyncing = false;
  String? _lastSyncMessage;

  // Periodic timer for live reverse countdown updates
  Timer? _liveTicker;

  // Getters
  List<FuelEntry> get fuelEntries => List.unmodifiable(_fuelEntries);
  MaintenanceSettings get maintenance => _maintenance;
  List<CountdownTimerItem> get countdowns => List.unmodifiable(_countdowns);
  List<KhaataEntry> get khaataEntries => List.unmodifiable(_khaataEntries);
  UserProfile get userProfile => _userProfile;
  bool get isDarkMode => _isDarkMode;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  String? get lastSyncMessage => _lastSyncMessage;
  bool get isSetupCompleted => _maintenance.isSetupCompleted;

  AppProvider() {
    _initApp();
  }

  Future<void> _initApp() async {
    _isLoading = true;
    notifyListeners();

    _isDarkMode = await StorageService.loadDarkMode();
    final profile = await StorageService.loadUserProfile();
    if (profile != null) _userProfile = profile;

    final maint = await StorageService.loadMaintenanceSettings();
    if (maint != null) _maintenance = maint;

    _fuelEntries = await StorageService.loadFuelEntries();
    _countdowns = await StorageService.loadCountdowns();
    _khaataEntries = await StorageService.loadKhaataEntries();

    // If first launch, seed with friendly initial demo data so app looks alive immediately
    if (_fuelEntries.isEmpty && _khaataEntries.isEmpty) {
      _seedInitialData();
    } else {
      _recalculateFuelEntries();
    }

    _isLoading = false;
    notifyListeners();

    // Start 1-second live ticker for countdowns
    _liveTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_countdowns.isNotEmpty) {
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _liveTicker?.cancel();
    super.dispose();
  }

  void _seedInitialData() {
    final now = DateTime.now();

    // Initial Maintenance setup
    _maintenance = MaintenanceSettings(
      vehicleName: 'Honda 125',
      currentOdometerKm: 12450.0,
      lastOilChangeKm: 11800.0,
      lastOilChangeDate: now.subtract(const Duration(days: 20)),
      oilChangeIntervalKm: 1000.0,
      lastTuningDate: now.subtract(const Duration(days: 42)),
      tuningIntervalDays: 60,
    );

    // Initial Fuel Logs
    final f1 = FuelEntry(
      id: _uuid.v4(),
      date: now.subtract(const Duration(days: 12)),
      odometerKm: 12000.0,
      amountSpent: 1200.0,
      liters: 4.25,
      notes: 'Shell Petrol Station',
      fuelStation: 'Shell F-7',
    );
    final f2 = FuelEntry(
      id: _uuid.v4(),
      date: now.subtract(const Duration(days: 6)),
      odometerKm: 12220.0,
      amountSpent: 1350.0,
      liters: 4.80,
      notes: 'Total Parco',
      fuelStation: 'Total Blue Area',
      distanceTraveled: 220.0,
      averageKmL: 45.83,
      costPerKm: 6.14,
    );
    final f3 = FuelEntry(
      id: _uuid.v4(),
      date: now.subtract(const Duration(days: 1)),
      odometerKm: 12450.0,
      amountSpent: 1400.0,
      liters: 4.95,
      notes: 'PSO Station',
      fuelStation: 'PSO Main',
      distanceTraveled: 230.0,
      averageKmL: 46.46,
      costPerKm: 6.09,
    );
    _fuelEntries = [f3, f2, f1];

    // Initial Khaata Entries
    _khaataEntries = [
      KhaataEntry(
        id: _uuid.v4(),
        title: 'Monthly Salary Received',
        amount: 85000.0,
        type: KhaataType.income,
        category: 'Salary',
        date: now.subtract(const Duration(days: 7)),
        paymentMethod: 'Bank Transfer',
        notes: 'Monthly company salary',
      ),
      KhaataEntry(
        id: _uuid.v4(),
        title: 'Bike Petrol (Total)',
        amount: 1350.0,
        type: KhaataType.expense,
        category: 'Fuel & Bike',
        date: now.subtract(const Duration(days: 6)),
        paymentMethod: 'Cash',
        notes: 'Fuel fill-up',
      ),
      KhaataEntry(
        id: _uuid.v4(),
        title: 'Engine Oil Change',
        amount: 1100.0,
        type: KhaataType.expense,
        category: 'Maintenance',
        date: now.subtract(const Duration(days: 20)),
        paymentMethod: 'Cash',
        notes: 'Havoline 20W-50 4T',
      ),
      KhaataEntry(
        id: _uuid.v4(),
        title: 'Home Grocery',
        amount: 8400.0,
        type: KhaataType.expense,
        category: 'Grocery',
        date: now.subtract(const Duration(days: 4)),
        paymentMethod: 'Card',
        notes: 'Monthly groceries',
      ),
      KhaataEntry(
        id: _uuid.v4(),
        title: 'Electricity & Internet Bill',
        amount: 6200.0,
        type: KhaataType.expense,
        category: 'Bills',
        date: now.subtract(const Duration(days: 3)),
        paymentMethod: 'EasyPaisa',
        notes: 'Utility bill payment',
      ),
      KhaataEntry(
        id: _uuid.v4(),
        title: 'Bike Petrol (PSO)',
        amount: 1400.0,
        type: KhaataType.expense,
        category: 'Fuel & Bike',
        date: now.subtract(const Duration(days: 1)),
        paymentMethod: 'Cash',
        notes: 'Fuel fill-up',
      ),
    ];

    // Initial Countdowns
    _countdowns = [
      CountdownTimerItem(
        id: _uuid.v4(),
        title: 'Air Filter Cleaning & Spark Plug Check',
        category: 'Maintenance',
        targetDate: now.add(const Duration(days: 4, hours: 8)),
        createdAt: now.subtract(const Duration(days: 10)),
        notes: 'Check air filter cleanliness and adjust spark plug gap',
      ),
      CountdownTimerItem(
        id: _uuid.v4(),
        title: 'Bike Chain Lubrication & Tightening',
        category: 'Maintenance',
        targetDate: now.add(const Duration(days: 2, hours: 14, minutes: 30)),
        createdAt: now.subtract(const Duration(days: 5)),
        notes: 'Clean chain with diesel and apply chain lube spray',
      ),
      CountdownTimerItem(
        id: _uuid.v4(),
        title: 'Bike Insurance Renewal',
        category: 'Documents',
        targetDate: now.add(const Duration(days: 18)),
        createdAt: now.subtract(const Duration(days: 12)),
        notes: 'Annual policy renewal',
      ),
    ];

    _saveAll();
  }

  // --- THEME & PREFERENCES ---
  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    await StorageService.saveDarkMode(_isDarkMode);
  }

  // --- USER AUTH & CLOUD SYNC ---
  Future<void> signInWithGoogle({
    required String email,
    required String displayName,
    String? photoUrl,
  }) async {
    _userProfile = _userProfile.copyWith(
      id: _uuid.v4(),
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      isLoggedIn: true,
      lastSyncedAt: DateTime.now(),
    );
    notifyListeners();
    await StorageService.saveUserProfile(_userProfile);
    await syncWithCloud();
  }

  Future<void> signOut() async {
    _userProfile = UserProfile(
      id: 'guest_user',
      email: 'guest@ridekhaata.app',
      displayName: 'Bike Rider',
      isLoggedIn: false,
    );
    notifyListeners();
    await StorageService.saveUserProfile(_userProfile);
  }

  Future<void> syncWithCloud() async {
    if (_isSyncing) return;
    _isSyncing = true;
    _lastSyncMessage = 'Syncing data to Google Account...';
    notifyListeners();

    final result = await SyncService.syncWithCloud(
      profile: _userProfile,
      fuelEntries: _fuelEntries,
      maintenance: _maintenance,
      countdowns: _countdowns,
      khaataEntries: _khaataEntries,
    );

    _isSyncing = false;
    _lastSyncMessage = result.message;
    if (result.success) {
      _userProfile = _userProfile.copyWith(lastSyncedAt: result.syncTime);
      await StorageService.saveUserProfile(_userProfile);
    }
    notifyListeners();
  }

  // --- VEHICLE ONBOARDING SETUP ---
  Future<void> completeVehicleSetup({
    required String vehicleName,
    required String registrationNumber,
    required double fuelTankCapacityLiters,
    required double currentOdometerKm,
    required double oilChangeIntervalKm,
    required int tuningIntervalDays,
    double? initialSalary,
    String currencySymbol = 'Rs.',
  }) async {
    _maintenance = _maintenance.copyWith(
      vehicleName: vehicleName,
      registrationNumber: registrationNumber,
      fuelTankCapacityLiters: fuelTankCapacityLiters,
      currentOdometerKm: currentOdometerKm,
      lastOilChangeKm: currentOdometerKm > 400 ? currentOdometerKm - 400 : 0,
      oilChangeIntervalKm: oilChangeIntervalKm,
      tuningIntervalDays: tuningIntervalDays,
      isSetupCompleted: true,
    );

    _userProfile = _userProfile.copyWith(
      currencySymbol: currencySymbol,
    );

    if (initialSalary != null && initialSalary > 0) {
      final salaryEntry = KhaataEntry(
        id: _uuid.v4(),
        title: 'Monthly Salary / Initial Balance',
        amount: initialSalary,
        type: KhaataType.income,
        category: 'Salary',
        date: DateTime.now(),
        paymentMethod: 'Bank Transfer',
        notes: 'Initial salary logged during onboarding setup',
      );
      _khaataEntries.insert(0, salaryEntry);
      await StorageService.saveKhaataEntries(_khaataEntries);
    }

    await StorageService.saveMaintenanceSettings(_maintenance);
    await StorageService.saveUserProfile(_userProfile);
    notifyListeners();
  }

  Future<void> resetVehicleSetup() async {
    _maintenance = _maintenance.copyWith(isSetupCompleted: false);
    await StorageService.saveMaintenanceSettings(_maintenance);
    notifyListeners();
  }

  // --- FUEL LOGIC & CALCULATIONS ---
  Future<void> addFuelEntry({
    required DateTime date,
    required double odometerKm,
    required double amountSpent,
    required double liters,
    String notes = '',
    String fuelStation = '',
    bool addToKhaata = true,
  }) async {
    final newEntry = FuelEntry(
      id: _uuid.v4(),
      date: date,
      odometerKm: odometerKm,
      amountSpent: amountSpent,
      liters: liters,
      notes: notes,
      fuelStation: fuelStation,
    );

    _fuelEntries.add(newEntry);
    _recalculateFuelEntries();

    // Update maintenance current odometer if newer
    if (odometerKm > _maintenance.currentOdometerKm) {
      _maintenance = _maintenance.copyWith(currentOdometerKm: odometerKm);
      await StorageService.saveMaintenanceSettings(_maintenance);
    }

    // Optionally auto-record in Khaata
    if (addToKhaata) {
      final khaata = KhaataEntry(
        id: _uuid.v4(),
        title: 'Fuel: ${fuelStation.isNotEmpty ? fuelStation : "Petrol"} ($liters L)',
        amount: amountSpent,
        type: KhaataType.expense,
        category: 'Fuel & Bike',
        date: date,
        paymentMethod: 'Cash',
        notes: 'Odometer: ${odometerKm.toStringAsFixed(0)} KM. $notes',
        relatedFuelId: newEntry.id,
      );
      _khaataEntries.insert(0, khaata);
      await StorageService.saveKhaataEntries(_khaataEntries);
    }

    await StorageService.saveFuelEntries(_fuelEntries);
    notifyListeners();
  }

  Future<void> deleteFuelEntry(String id) async {
    _fuelEntries.removeWhere((e) => e.id == id);
    _recalculateFuelEntries();

    // Also remove any related khaata entry
    _khaataEntries.removeWhere((e) => e.relatedFuelId == id);

    await StorageService.saveFuelEntries(_fuelEntries);
    await StorageService.saveKhaataEntries(_khaataEntries);
    notifyListeners();
  }

  void _recalculateFuelEntries() {
    if (_fuelEntries.isEmpty) return;

    // Sort chronologically ascending to compute diffs
    _fuelEntries.sort((a, b) => a.date.compareTo(b.date));

    final List<FuelEntry> calculated = [];
    for (int i = 0; i < _fuelEntries.length; i++) {
      final current = _fuelEntries[i];
      if (i == 0) {
        // First entry: no previous distance reference
        calculated.add(current.copyWith(
          distanceTraveled: null,
          averageKmL: null,
          costPerKm: null,
        ));
      } else {
        final prev = _fuelEntries[i - 1];
        final dist = (current.odometerKm - prev.odometerKm).clamp(0, double.infinity).toDouble();
        final avg = (current.liters > 0 && dist > 0) ? (dist / current.liters) : null;
        final cost = (dist > 0) ? (current.amountSpent / dist) : null;

        calculated.add(current.copyWith(
          distanceTraveled: dist,
          averageKmL: avg,
          costPerKm: cost,
        ));
      }
    }

    // Reverse to show most recent entries first in the UI
    _fuelEntries = calculated.reversed.toList();
  }

  // Aggregate Fuel Statistics
  double get latestOdometer {
    if (_fuelEntries.isNotEmpty) {
      return _fuelEntries.first.odometerKm;
    }
    return _maintenance.currentOdometerKm;
  }

  double get overallAverageKmL {
    double totalDist = 0;
    double totalLiters = 0;
    for (final e in _fuelEntries) {
      if (e.distanceTraveled != null && e.distanceTraveled! > 0) {
        totalDist += e.distanceTraveled!;
        totalLiters += e.liters;
      }
    }
    if (totalLiters == 0) return 0.0;
    return totalDist / totalLiters;
  }

  double get totalFuelSpent {
    return _fuelEntries.fold(0.0, (sum, e) => sum + e.amountSpent);
  }

  double get totalFuelLiters {
    return _fuelEntries.fold(0.0, (sum, e) => sum + e.liters);
  }

  // --- MAINTENANCE & REMINDERS LOGIC ---
  Future<void> updateMaintenanceSettings({
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
  }) async {
    _maintenance = _maintenance.copyWith(
      vehicleName: vehicleName,
      registrationNumber: registrationNumber,
      currentOdometerKm: currentOdometerKm,
      fuelTankCapacityLiters: fuelTankCapacityLiters,
      lastOilChangeKm: lastOilChangeKm,
      lastOilChangeDate: lastOilChangeDate,
      oilChangeIntervalKm: oilChangeIntervalKm,
      lastTuningDate: lastTuningDate,
      tuningIntervalDays: tuningIntervalDays,
      isSetupCompleted: isSetupCompleted,
    );
    await StorageService.saveMaintenanceSettings(_maintenance);
    notifyListeners();
  }

  Future<void> logOilChangeDone({double? cost, String? notes}) async {
    final now = DateTime.now();
    final odo = latestOdometer;

    _maintenance = _maintenance.copyWith(
      lastOilChangeKm: odo,
      lastOilChangeDate: now,
    );
    await StorageService.saveMaintenanceSettings(_maintenance);

    if (cost != null && cost > 0) {
      await addKhaataEntry(
        title: 'Oil Change (${_maintenance.vehicleName})',
        amount: cost,
        type: KhaataType.expense,
        category: 'Maintenance',
        date: now,
        notes: notes ?? 'Oil change at ${odo.toStringAsFixed(0)} KM',
      );
    }
    notifyListeners();
  }

  Future<void> logTuningDone({double? cost, String? notes}) async {
    final now = DateTime.now();
    _maintenance = _maintenance.copyWith(
      lastTuningDate: now,
    );
    await StorageService.saveMaintenanceSettings(_maintenance);

    if (cost != null && cost > 0) {
      await addKhaataEntry(
        title: 'Bike Tuning & Service',
        amount: cost,
        type: KhaataType.expense,
        category: 'Maintenance',
        date: now,
        notes: notes ?? 'Full tuning & carburetor/plug service',
      );
    }
    notifyListeners();
  }

  // --- COUNTDOWN TIMERS ---
  Future<void> addCountdown({
    required String title,
    required String category,
    required DateTime targetDate,
    String notes = '',
  }) async {
    final item = CountdownTimerItem(
      id: _uuid.v4(),
      title: title,
      category: category,
      targetDate: targetDate,
      createdAt: DateTime.now(),
      notes: notes,
    );
    _countdowns.insert(0, item);
    await StorageService.saveCountdowns(_countdowns);
    notifyListeners();
  }

  Future<void> deleteCountdown(String id) async {
    _countdowns.removeWhere((c) => c.id == id);
    await StorageService.saveCountdowns(_countdowns);
    notifyListeners();
  }

  Future<void> toggleCountdownComplete(String id) async {
    final index = _countdowns.indexWhere((c) => c.id == id);
    if (index != -1) {
      final current = _countdowns[index];
      _countdowns[index] = current.copyWith(isCompleted: !current.isCompleted);
      await StorageService.saveCountdowns(_countdowns);
      notifyListeners();
    }
  }

  // --- KHAATA (INCOME / SALARY / EXPENSE / REPORT) ---
  Future<void> addKhaataEntry({
    required String title,
    required double amount,
    required KhaataType type,
    required String category,
    required DateTime date,
    String paymentMethod = 'Cash',
    String notes = '',
    String? relatedFuelId,
  }) async {
    final entry = KhaataEntry(
      id: _uuid.v4(),
      title: title,
      amount: amount,
      type: type,
      category: category,
      date: date,
      paymentMethod: paymentMethod,
      notes: notes,
      relatedFuelId: relatedFuelId,
    );
    _khaataEntries.insert(0, entry);
    await StorageService.saveKhaataEntries(_khaataEntries);
    notifyListeners();
  }

  Future<void> deleteKhaataEntry(String id) async {
    _khaataEntries.removeWhere((e) => e.id == id);
    await StorageService.saveKhaataEntries(_khaataEntries);
    notifyListeners();
  }

  double get totalIncome => _khaataEntries
      .where((e) => e.isIncome)
      .fold(0.0, (sum, e) => sum + e.amount);

  double get totalExpense => _khaataEntries
      .where((e) => e.isExpense)
      .fold(0.0, (sum, e) => sum + e.amount);

  double get netBalance => totalIncome - totalExpense;

  Map<String, double> get expensesByCategory {
    final Map<String, double> result = {};
    for (final e in _khaataEntries.where((item) => item.isExpense)) {
      result[e.category] = (result[e.category] ?? 0.0) + e.amount;
    }
    return result;
  }

  // Backup & save all
  Future<void> _saveAll() async {
    await StorageService.saveFuelEntries(_fuelEntries);
    await StorageService.saveMaintenanceSettings(_maintenance);
    await StorageService.saveCountdowns(_countdowns);
    await StorageService.saveKhaataEntries(_khaataEntries);
  }
}
