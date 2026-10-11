import 'dart:convert';

enum KhaataType { income, expense }

class KhaataEntry {
  final String id;
  final String title;
  final double amount;
  final KhaataType type;
  final String category;
  final DateTime date;
  final String paymentMethod;
  final String notes;
  final String? relatedFuelId;

  KhaataEntry({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.paymentMethod = 'Cash',
    this.notes = '',
    this.relatedFuelId,
  });

  bool get isIncome => type == KhaataType.income;
  bool get isExpense => type == KhaataType.expense;

  KhaataEntry copyWith({
    String? id,
    String? title,
    double? amount,
    KhaataType? type,
    String? category,
    DateTime? date,
    String? paymentMethod,
    String? notes,
    String? relatedFuelId,
  }) {
    return KhaataEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      relatedFuelId: relatedFuelId ?? this.relatedFuelId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type.name,
      'category': category,
      'date': date.toIso8601String(),
      'paymentMethod': paymentMethod,
      'notes': notes,
      'relatedFuelId': relatedFuelId,
    };
  }

  factory KhaataEntry.fromMap(Map<String, dynamic> map) {
    return KhaataEntry(
      id: map['id'] as String,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: (map['type'] as String) == 'income'
          ? KhaataType.income
          : KhaataType.expense,
      category: (map['category'] as String?) ?? 'General',
      date: DateTime.parse(map['date'] as String),
      paymentMethod: (map['paymentMethod'] as String?) ?? 'Cash',
      notes: (map['notes'] as String?) ?? '',
      relatedFuelId: map['relatedFuelId'] as String?,
    );
  }

  String toJson() => json.encode(toMap());
  factory KhaataEntry.fromJson(String source) =>
      KhaataEntry.fromMap(json.decode(source) as Map<String, dynamic>);
}
