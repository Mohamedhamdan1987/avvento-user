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
      day: json['day']?.toString() ?? '',
      isClosed: json['isClosed'] == true,
      openTime: json['openTime']?.toString() ?? '00:00',
      closeTime: json['closeTime']?.toString() ?? '23:59',
      note: json['note']?.toString() ?? '',
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
      day: json['day']?.toString() ?? '',
      isClosed: json['isClosed'] == true,
      openTime: json['openTime']?.toString() ?? '00:00',
      closeTime: json['closeTime']?.toString() ?? '23:59',
      note: json['note']?.toString() ?? '',
      isCurrentlyOpen: json['isCurrentlyOpen'] == true,
    );
  }
}

class RestaurantSchedule {
  final String restaurantId;
  final List<WeeklySchedule> weeklySchedule;
  final bool isOpen;
  final CurrentDayStatus currentDayStatus;
  final DateTime? lastUpdatedAt;

  RestaurantSchedule({
    required this.restaurantId,
    required this.weeklySchedule,
    required this.isOpen,
    required this.currentDayStatus,
    this.lastUpdatedAt,
  });

  factory RestaurantSchedule.fromJson(Map<String, dynamic> json) {
    final lastUpdatedAtRaw = json['lastUpdatedAt'];
    final weeklyScheduleRaw = json['weeklySchedule'];
    final currentDayStatusRaw = json['currentDayStatus'];
    return RestaurantSchedule(
      restaurantId: json['restaurantId']?.toString() ?? '',
      weeklySchedule: weeklyScheduleRaw is List
          ? (weeklyScheduleRaw)
              .map((e) => WeeklySchedule.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList()
          : [],
      isOpen: json['isOpen'] == true,
      currentDayStatus: currentDayStatusRaw is Map
          ? CurrentDayStatus.fromJson(Map<String, dynamic>.from(currentDayStatusRaw))
          : CurrentDayStatus(
              day: '',
              isClosed: true,
              openTime: '00:00',
              closeTime: '23:59',
              note: '',
              isCurrentlyOpen: false,
            ),
      lastUpdatedAt: lastUpdatedAtRaw != null
          ? DateTime.tryParse(lastUpdatedAtRaw.toString())
          : null,
    );
  }
}
