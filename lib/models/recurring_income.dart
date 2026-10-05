class RecurringIncome {
  final int? id;
  final String name;
  final int amount; // VND
  final String category;
  final String frequency; // daily, weekly, monthly, yearly
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime nextDate;
  final bool enabled;
  final String? note;
  final int? walletId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RecurringIncome({
    this.id,
    required this.name,
    required this.amount,
    required this.category,
    this.frequency = 'monthly',
    required this.startDate,
    this.endDate,
    required this.nextDate,
    this.enabled = true,
    this.note,
    this.walletId,
    required this.createdAt,
    required this.updatedAt,
  });

  RecurringIncome copyWith({
    int? id,
    String? name,
    int? amount,
    String? category,
    String? frequency,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? nextDate,
    bool? enabled,
    String? note,
    int? walletId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecurringIncome(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      nextDate: nextDate ?? this.nextDate,
      enabled: enabled ?? this.enabled,
      note: note ?? this.note,
      walletId: walletId ?? this.walletId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'category': category,
      'frequency': frequency,
      'start_date': startDate.toIso8601String().substring(0, 10),
      'end_date': endDate?.toIso8601String().substring(0, 10),
      'next_date': nextDate.toIso8601String().substring(0, 10),
      'enabled': enabled ? 1 : 0,
      'note': note,
      'wallet_id': walletId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory RecurringIncome.fromMap(Map<String, dynamic> map) {
    return RecurringIncome(
      id: map['id'] as int?,
      name: map['name'] as String,
      amount: map['amount'] as int,
      category: map['category'] as String,
      frequency: map['frequency'] as String? ?? 'monthly',
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: map['end_date'] != null
          ? DateTime.parse(map['end_date'] as String)
          : null,
      nextDate: DateTime.parse(map['next_date'] as String),
      enabled: (map['enabled'] as int? ?? 1) == 1,
      note: map['note'] as String?,
      walletId: map['wallet_id'] as int?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory RecurringIncome.fromJson(Map<String, dynamic> json) =>
      RecurringIncome.fromMap(json);
}
