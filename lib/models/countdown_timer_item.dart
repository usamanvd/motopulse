import 'dart:convert';

class CountdownTimerItem {
  final String id;
  final String title;
  final String category;
  final DateTime targetDate;
  final DateTime createdAt;
  final bool isCompleted;
  final String notes;

  CountdownTimerItem({
    required this.id,
    required this.title,
    this.category = 'Bike',
    required this.targetDate,
    required this.createdAt,
    this.isCompleted = false,
    this.notes = '',
  });

  Duration get remainingDuration {
    final now = DateTime.now();
    if (now.isAfter(targetDate)) {
      return Duration.zero;
    }
    return targetDate.difference(now);
  }

  bool get isExpired => DateTime.now().isAfter(targetDate);

  int get remainingDays => remainingDuration.inDays;
  int get remainingHours => remainingDuration.inHours % 24;
  int get remainingMinutes => remainingDuration.inMinutes % 60;
  int get remainingSeconds => remainingDuration.inSeconds % 60;

  double get progressPercentage {
    final total = targetDate.difference(createdAt).inSeconds;
    if (total <= 0) return 1.0;
    final elapsed = DateTime.now().difference(createdAt).inSeconds;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  CountdownTimerItem copyWith({
    String? id,
    String? title,
    String? category,
    DateTime? targetDate,
    DateTime? createdAt,
    bool? isCompleted,
    String? notes,
  }) {
    return CountdownTimerItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'targetDate': targetDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'isCompleted': isCompleted,
      'notes': notes,
    };
  }

  factory CountdownTimerItem.fromMap(Map<String, dynamic> map) {
    return CountdownTimerItem(
      id: map['id'] as String,
      title: map['title'] as String,
      category: (map['category'] as String?) ?? 'Bike',
      targetDate: DateTime.parse(map['targetDate'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
      isCompleted: (map['isCompleted'] as bool?) ?? false,
      notes: (map['notes'] as String?) ?? '',
    );
  }

  String toJson() => json.encode(toMap());
  factory CountdownTimerItem.fromJson(String source) =>
      CountdownTimerItem.fromMap(json.decode(source) as Map<String, dynamic>);
}
