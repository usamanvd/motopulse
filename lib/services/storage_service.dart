import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/fuel_entry.dart';
import '../models/maintenance_settings.dart';
import '../models/countdown_timer_item.dart';
import '../models/khaata_entry.dart';
import '../models/user_profile.dart';

class StorageService {
  static const String _keyFuelEntries = 'ride_khaata_fuel_entries';
  static const String _keyMaintenance = 'ride_khaata_maintenance';
  static const String _keyCountdowns = 'ride_khaata_countdowns';
  static const String _keyKhaata = 'ride_khaata_transactions';
  static const String _keyUserProfile = 'ride_khaata_user_profile';
  static const String _keyThemeMode = 'ride_khaata_theme_mode';

  // Fuel Entries
  static Future<List<FuelEntry>> loadFuelEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyFuelEntries);
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      final List decoded = json.decode(jsonString);
      return decoded.map((e) => FuelEntry.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveFuelEntries(List<FuelEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(entries.map((e) => e.toMap()).toList());
    await prefs.setString(_keyFuelEntries, jsonString);
  }

  // Maintenance Settings
  static Future<MaintenanceSettings?> loadMaintenanceSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyMaintenance);
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      final decoded = json.decode(jsonString);
      return MaintenanceSettings.fromMap(decoded as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  static Future<void> saveMaintenanceSettings(MaintenanceSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMaintenance, settings.toJson());
  }

  // Countdown Timers
  static Future<List<CountdownTimerItem>> loadCountdowns() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyCountdowns);
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      final List decoded = json.decode(jsonString);
      return decoded.map((e) => CountdownTimerItem.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveCountdowns(List<CountdownTimerItem> timers) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(timers.map((e) => e.toMap()).toList());
    await prefs.setString(_keyCountdowns, jsonString);
  }

  // Khaata Transactions
  static Future<List<KhaataEntry>> loadKhaataEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyKhaata);
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      final List decoded = json.decode(jsonString);
      return decoded.map((e) => KhaataEntry.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveKhaataEntries(List<KhaataEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(entries.map((e) => e.toMap()).toList());
    await prefs.setString(_keyKhaata, jsonString);
  }

  // User Profile
  static Future<UserProfile?> loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyUserProfile);
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      return UserProfile.fromJson(jsonString);
    } catch (e) {
      return null;
    }
  }

  static Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserProfile, profile.toJson());
  }

  // Theme Mode
  static Future<bool> loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyThemeMode) ?? false;
  }

  static Future<void> saveDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyThemeMode, isDark);
  }

  // Clear / Reset All
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
