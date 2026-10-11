import 'dart:convert';

class UserProfile {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final bool isLoggedIn;
  final DateTime? lastSyncedAt;
  final String currencySymbol; // 'Rs.' or '$'
  final String distanceUnit; // 'KM'
  final String fuelUnit; // 'L'

  UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.isLoggedIn = false,
    this.lastSyncedAt,
    this.currencySymbol = 'Rs.',
    this.distanceUnit = 'KM',
    this.fuelUnit = 'L',
  });

  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? isLoggedIn,
    DateTime? lastSyncedAt,
    String? currencySymbol,
    String? distanceUnit,
    String? fuelUnit,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      distanceUnit: distanceUnit ?? this.distanceUnit,
      fuelUnit: fuelUnit ?? this.fuelUnit,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'isLoggedIn': isLoggedIn,
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
      'currencySymbol': currencySymbol,
      'distanceUnit': distanceUnit,
      'fuelUnit': fuelUnit,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: (map['id'] as String?) ?? 'guest_user',
      email: (map['email'] as String?) ?? 'guest@ridekhaata.app',
      displayName: (map['displayName'] as String?) ?? 'Rider',
      photoUrl: map['photoUrl'] as String?,
      isLoggedIn: (map['isLoggedIn'] as bool?) ?? false,
      lastSyncedAt: map['lastSyncedAt'] != null
          ? DateTime.parse(map['lastSyncedAt'] as String)
          : null,
      currencySymbol: (map['currencySymbol'] as String?) ?? 'Rs.',
      distanceUnit: (map['distanceUnit'] as String?) ?? 'KM',
      fuelUnit: (map['fuelUnit'] as String?) ?? 'L',
    );
  }

  String toJson() => json.encode(toMap());
  factory UserProfile.fromJson(String source) =>
      UserProfile.fromMap(json.decode(source) as Map<String, dynamic>);
}
