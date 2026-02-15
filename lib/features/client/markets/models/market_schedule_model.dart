import '../../restaurants/models/restaurant_schedule_model.dart';

class MarketSchedule {
  final String marketId;
  final List<WeeklySchedule> weeklySchedule;
  final bool isOpen;
  final CurrentDayStatus currentDayStatus;
  final DateTime? lastUpdatedAt;

  MarketSchedule({
    required this.marketId,
    required this.weeklySchedule,
    required this.isOpen,
    required this.currentDayStatus,
    this.lastUpdatedAt,
  });

  factory MarketSchedule.fromJson(Map<String, dynamic> json) {
    return MarketSchedule(
      marketId: json['marketId'] as String,
      weeklySchedule: (json['weeklySchedule'] as List<dynamic>)
          .map((e) => WeeklySchedule.fromJson(e as Map<String, dynamic>))
          .toList(),
      isOpen: json['isOpen'] as bool,
      currentDayStatus:
          CurrentDayStatus.fromJson(json['currentDayStatus'] as Map<String, dynamic>),
      lastUpdatedAt: json['lastUpdatedAt'] != null
          ? DateTime.tryParse(json['lastUpdatedAt'] as String)
          : null,
    );
  }
}
