class Wallet {
  final int? id;
  final String name;
  final String type; // cash, bank, ewallet, savings, other
  final int balance; // VND
  final String? note;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Wallet({
    this.id,
    required this.name,
    this.type = 'cash',
    this.balance = 0,
    this.note,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Wallet copyWith({
    int? id,
    String? name,
    String? type,
    int? balance,
    String? note,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Wallet(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      note: note ?? this.note,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'balance': balance,
      'note': note,
      'is_default': isDefault ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Wallet.fromMap(Map<String, dynamic> map) {
    return Wallet(
      id: map['id'] as int?,
      name: map['name'] as String,
      type: map['type'] as String? ?? 'cash',
      balance: map['balance'] as int? ?? 0,
      note: map['note'] as String?,
      isDefault: (map['is_default'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet.fromMap(json);
}
