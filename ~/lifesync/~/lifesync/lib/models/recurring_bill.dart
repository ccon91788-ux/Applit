class RecurringBill {
  final int? id;
  final String name;
  final int amount; // VND
  final String category;
  final int dueDay; // 1-31
  final String? note;
  final bool enabled;
  final DateTime nextDueDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RecurringBill({
    this.id,
    required this.name,
    required this.amount,
    required this.category,
    required this.dueDay,
    this.note,
    this.enabled = true,
    required this.nextDueDate,
    required this.createdAt,
    required this.updatedAt,
  });

  RecurringBill copyWith({
    int? id,
    String? name,
    int? amount,
    String? category,
    int? dueDay,
    String? note,
    bool? enabled,
    DateTime? nextDueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecurringBill(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      dueDay: dueDay ?? this.dueDay,
      note: note ?? this.note,
      enabled: enabled ?? this.enabled,
      nextDueDate: nextDueDate ?? this.nextDueDate,
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
      'due_day': dueDay,
      'note': note,
      'enabled': enabled ? 1 : 0,
      'next_due_date': nextDueDate.toIso8601String().substring(0, 10),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory RecurringBill.fromMap(Map<String, dynamic> map) {
    return RecurringBill(
      id: map['id'] as int?,
      name: map['name'] as String,
      amount: map['amount'] as int,
      category: map['category'] as String,
      dueDay: map['due_day'] as int,
      note: map['note'] as String?,
      enabled: (map['enabled'] as int? ?? 1) == 1,
      nextDueDate: DateTime.parse(map['next_due_date'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory RecurringBill.fromJson(Map<String, dynamic> json) =>
      RecurringBill.fromMap(json);
}
