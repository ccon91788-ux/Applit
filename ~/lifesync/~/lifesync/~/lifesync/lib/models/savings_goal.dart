class SavingsGoal {
  final int? id;
  final String name;
  final int targetAmount; // VND
  final int currentAmount; // VND
  final DateTime? deadline;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SavingsGoal({
    this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0,
    this.deadline,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  double get progress {
    if (targetAmount <= 0) return 0;
    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }

  int get remaining => (targetAmount - currentAmount).clamp(0, targetAmount);

  SavingsGoal copyWith({
    int? id,
    String? name,
    int? targetAmount,
    int? currentAmount,
    DateTime? deadline,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'deadline': deadline?.toIso8601String().substring(0, 10),
      'note': note,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory SavingsGoal.fromMap(Map<String, dynamic> map) {
    return SavingsGoal(
      id: map['id'] as int?,
      name: map['name'] as String,
      targetAmount: map['target_amount'] as int,
      currentAmount: map['current_amount'] as int? ?? 0,
      deadline: map['deadline'] != null
          ? DateTime.parse(map['deadline'] as String)
          : null,
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory SavingsGoal.fromJson(Map<String, dynamic> json) =>
      SavingsGoal.fromMap(json);
}
