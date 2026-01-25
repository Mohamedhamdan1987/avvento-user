class WeeklySchedule {
  final String day;
  final bool isClosed;
  final String openTime;
  final String closeTime;
  final String note;

  WeeklySchedule({
    required this.day,
    required this.isClosed,
    required this.openTime,
    required this.closeTime,
    required this.note,
  });

  factory WeeklySchedule.fromJson(Map<String, dynamic> json) {
    return WeeklySchedule(
      day: json['day'] as String,
      isClosed: json['isClosed'] as bool,
      openTime: json['openTime'] as String,
      closeTime: json['closeTime'] as String,
      note: json['note'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'isClosed': isClosed,
      'openTime': openTime,
      'closeTime': closeTime,
      'note': note,
    };
  }
}

class CurrentDayStatus {
  final String day;
  final bool isClosed;
  final String openTime;
  final String closeTime;
  final String note;
  final bool isCurrentlyOpen;

  CurrentDayStatus({
    required this.day,
    required this.isClosed,
    required this.openTime,
    required this.closeTime,
    required this.note,
    required this.isCurrentlyOpen,
  });

  factory CurrentDayStatus.fromJson(Map<String, dynamic> json) {
    return CurrentDayStatus(
      day: json['day'] as String,
      isClosed: json['isClosed'] as bool,
      openTime: json['openTime'] as String,
      closeTime: json['closeTime'] as String,
      note: json['note'] as String? ?? '',
      isCurrentlyOpen: json['isCurrentlyOpen'] as bool,
    );
  }
}

class RestaurantSchedule {
  final String restaurantId;
  final List<WeeklySchedule> weeklySchedule;
  final bool isOpen;
  final CurrentDayStatus currentDayStatus;
  final DateTime lastUpdatedAt;

  RestaurantSchedule({
    required this.restaurantId,
    required this.weeklySchedule,
    required this.isOpen,
    required this.currentDayStatus,
    required this.lastUpdatedAt,
  });

  factory RestaurantSchedule.fromJson(Map<String, dynamic> json) {
    return RestaurantSchedule(
      restaurantId: json['restaurantId'] as String,
      weeklySchedule: (json['weeklySchedule'] as List<dynamic>)
          .map((e) => WeeklySchedule.fromJson(e as Map<String, dynamic>))
          .toList(),
      isOpen: json['isOpen'] as bool,
      currentDayStatus: CurrentDayStatus.fromJson(json['currentDayStatus'] as Map<String, dynamic>),
      lastUpdatedAt: DateTime.parse(json['lastUpdatedAt'] as String),
    );
  }
}
