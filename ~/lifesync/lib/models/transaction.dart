/// Transaction model — amount stored as integer VND to avoid floating-point errors.
class Transaction {
  final int? id;
  final String type; // 'income' | 'expense'
  final int amount; // VND, integer
  final String category;
  final String? note;
  final DateTime date;
  final String? time; // optional HH:mm
  final int? walletId;
  final String? source; // e.g. 'manual', 'recurring_bill', 'recurring_income'
  final int? sourceId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Transaction({
    this.id,
    required this.type,
    required this.amount,
    required this.category,
    this.note,
    required this.date,
    this.time,
    this.walletId,
    this.source,
    this.sourceId,
    required this.createdAt,
    required this.updatedAt,
  });

  Transaction copyWith({
    int? id,
    String? type,
    int? amount,
    String? category,
    String? note,
    DateTime? date,
    String? time,
    int? walletId,
    String? source,
    int? sourceId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      note: note ?? this.note,
      date: date ?? this.date,
      time: time ?? this.time,
      walletId: walletId ?? this.walletId,
      source: source ?? this.source,
      sourceId: sourceId ?? this.sourceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'category': category,
      'note': note,
      'date': date.toIso8601String().substring(0, 10),
      'time': time,
      'wallet_id': walletId,
      'source': source,
      'source_id': sourceId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int?,
      type: map['type'] as String,
      amount: map['amount'] as int,
      category: map['category'] as String,
      note: map['note'] as String?,
      date: DateTime.parse(map['date'] as String),
      time: map['time'] as String?,
      walletId: map['wallet_id'] as int?,
      source: map['source'] as String?,
      sourceId: map['source_id'] as int?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      Transaction.fromMap(json);
}
