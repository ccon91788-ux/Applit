/// Calendar event with recurrence and reminder support.
class Event {
  final int? id;
  final String title;
  final String? description;
  final DateTime date;
  final String startTime; // HH:mm
  final String? endTime;
  final String?
  reminder; // e.g. 'at_time', '5m', '10m', '15m', '30m', '1h', '1d'
  final String repeat; // 'none', 'daily', 'weekly', 'monthly', 'yearly'
  final bool notificationSound;
  final bool vibration;
  final int? color; // ARGB color value
  final String? labels; // comma-separated labels/tags
  final String? note;
  final DateTime? repeatEndDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Event({
    this.id,
    required this.title,
    this.description,
    required this.date,
    required this.startTime,
    this.endTime,
    this.reminder,
    this.repeat = 'none',
    this.notificationSound = true,
    this.vibration = true,
    this.color,
    this.labels,
    this.note,
    this.repeatEndDate,
    required this.createdAt,
    required this.updatedAt,
  });

  Event copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? date,
    String? startTime,
    String? endTime,
    String? reminder,
    String? repeat,
    bool? notificationSound,
    bool? vibration,
    int? color,
    String? labels,
    String? note,
    DateTime? repeatEndDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      reminder: reminder ?? this.reminder,
      repeat: repeat ?? this.repeat,
      notificationSound: notificationSound ?? this.notificationSound,
      vibration: vibration ?? this.vibration,
      color: color ?? this.color,
      labels: labels ?? this.labels,
      note: note ?? this.note,
      repeatEndDate: repeatEndDate ?? this.repeatEndDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String().substring(0, 10),
      'start_time': startTime,
      'end_time': endTime,
      'reminder': reminder,
      'repeat': repeat,
      'notification_sound': notificationSound ? 1 : 0,
      'vibration': vibration ? 1 : 0,
      'color': color,
      'labels': labels,
      'note': note,
      'repeat_end_date': repeatEndDate?.toIso8601String().substring(0, 10),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?,
      date: DateTime.parse(map['date'] as String),
      startTime: map['start_time'] as String,
      endTime: map['end_time'] as String?,
      reminder: map['reminder'] as String?,
      repeat: map['repeat'] as String? ?? 'none',
      notificationSound: (map['notification_sound'] as int? ?? 1) == 1,
      vibration: (map['vibration'] as int? ?? 1) == 1,
      color: map['color'] as int?,
      labels: map['labels'] as String?,
      note: map['note'] as String?,
      repeatEndDate: map['repeat_end_date'] != null
          ? DateTime.parse(map['repeat_end_date'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory Event.fromJson(Map<String, dynamic> json) => Event.fromMap(json);
}
