import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/fuel_entry.dart';
import '../models/maintenance_settings.dart';
import '../models/countdown_timer_item.dart';
import '../models/khaata_entry.dart';
import '../models/user_profile.dart';

class SyncResult {
  final bool success;
  final String message;
  final DateTime syncTime;

  SyncResult({
    required this.success,
    required this.message,
    required this.syncTime,
  });
}

class SyncService {
  // Simulates cloud sync with Google Account / Firebase Firestore
  static Future<SyncResult> syncWithCloud({
    required UserProfile profile,
    required List<FuelEntry> fuelEntries,
    required MaintenanceSettings maintenance,
    required List<CountdownTimerItem> countdowns,
    required List<KhaataEntry> khaataEntries,
  }) async {
    try {
      // Simulate network request to Google Cloud / Firebase
      await Future.delayed(const Duration(milliseconds: 1400));

      final syncPayload = {
        'userId': profile.id,
        'userEmail': profile.email,
        'timestamp': DateTime.now().toIso8601String(),
        'fuelEntriesCount': fuelEntries.length,
        'maintenance': maintenance.toMap(),
        'countdownsCount': countdowns.length,
        'khaataCount': khaataEntries.length,
      };

      if (kDebugMode) {
        print('Cloud Sync Successful: ${json.encode(syncPayload)}');
      }

      return SyncResult(
        success: true,
        message: 'All bike logs and Khaata data successfully synced to your Google Account.',
        syncTime: DateTime.now(),
      );
    } catch (e) {
      return SyncResult(
        success: false,
        message: 'Sync failed: $e',
        syncTime: DateTime.now(),
      );
    }
  }

  // Backup data to JSON string for local file export / sharing
  static String exportBackupJson({
    required UserProfile profile,
    required List<FuelEntry> fuelEntries,
    required MaintenanceSettings maintenance,
    required List<CountdownTimerItem> countdowns,
    required List<KhaataEntry> khaataEntries,
  }) {
    final data = {
      'version': '1.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'profile': profile.toMap(),
      'fuelEntries': fuelEntries.map((e) => e.toMap()).toList(),
      'maintenance': maintenance.toMap(),
      'countdowns': countdowns.map((e) => e.toMap()).toList(),
      'khaataEntries': khaataEntries.map((e) => e.toMap()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }
}
