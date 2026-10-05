class Budget {
  final int? id;
  final int year;
  final int month; // 1-12
  final int amount; // VND
  final bool alertsEnabled;
  final bool alert80Triggered;
  final bool alert90Triggered;
  final bool alert100Triggered;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Budget({
    this.id,
    required this.year,
    required this.month,
    required this.amount,
    this.alertsEnabled = true,
    this.alert80Triggered = false,
    this.alert90Triggered = false,
    this.alert100Triggered = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Budget copyWith({
    int? id,
    int? year,
    int? month,
    int? amount,
    bool? alertsEnabled,
    bool? alert80Triggered,
    bool? alert90Triggered,
    bool? alert100Triggered,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id ?? this.id,
      year: year ?? this.year,
      month: month ?? this.month,
      amount: amount ?? this.amount,
      alertsEnabled: alertsEnabled ?? this.alertsEnabled,
      alert80Triggered: alert80Triggered ?? this.alert80Triggered,
      alert90Triggered: alert90Triggered ?? this.alert90Triggered,
      alert100Triggered: alert100Triggered ?? this.alert100Triggered,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'year': year,
      'month': month,
      'amount': amount,
      'alerts_enabled': alertsEnabled ? 1 : 0,
      'alert_80_triggered': alert80Triggered ? 1 : 0,
      'alert_90_triggered': alert90Triggered ? 1 : 0,
      'alert_100_triggered': alert100Triggered ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] as int?,
      year: map['year'] as int,
      month: map['month'] as int,
      amount: map['amount'] as int,
      alertsEnabled: (map['alerts_enabled'] as int? ?? 1) == 1,
      alert80Triggered: (map['alert_80_triggered'] as int? ?? 0) == 1,
      alert90Triggered: (map['alert_90_triggered'] as int? ?? 0) == 1,
      alert100Triggered: (map['alert_100_triggered'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory Budget.fromJson(Map<String, dynamic> json) => Budget.fromMap(json);
}
