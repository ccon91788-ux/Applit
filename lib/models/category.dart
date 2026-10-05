class Category {
  final int? id;
  final String name;
  final String type; // income | expense
  final int? budgetLimit; // optional per-category budget (expense only)
  final int? color;
  final String? icon;
  final bool isDefault;
  final DateTime createdAt;

  const Category({
    this.id,
    required this.name,
    required this.type,
    this.budgetLimit,
    this.color,
    this.icon,
    this.isDefault = false,
    required this.createdAt,
  });

  Category copyWith({
    int? id,
    String? name,
    String? type,
    int? budgetLimit,
    int? color,
    String? icon,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      budgetLimit: budgetLimit ?? this.budgetLimit,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'budget_limit': budgetLimit,
      'color': color,
      'icon': icon,
      'is_default': isDefault ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      type: map['type'] as String,
      budgetLimit: map['budget_limit'] as int?,
      color: map['color'] as int?,
      icon: map['icon'] as String?,
      isDefault: (map['is_default'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory Category.fromJson(Map<String, dynamic> json) =>
      Category.fromMap(json);
}
