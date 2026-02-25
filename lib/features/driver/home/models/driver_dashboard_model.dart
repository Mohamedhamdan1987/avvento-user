import '../models/driver_order_model.dart';

class DriverDashboardModel {
  final int deliveredOrders;
  final int totalRatings;
  final double averageRating;
  final double acceptancePercentage;
  final double totalEarnings;
  final List<EarningsChartData> earningsChart;
  final List<DriverOrderModel> recentActivities;

  DriverDashboardModel({
    required this.deliveredOrders,
    required this.totalRatings,
    required this.averageRating,
    required this.acceptancePercentage,
    required this.totalEarnings,
    required this.earningsChart,
    required this.recentActivities,
  });

  factory DriverDashboardModel.fromJson(Map<String, dynamic> json) {
    return DriverDashboardModel(
      deliveredOrders: json['deliveredOrders'] as int? ?? 0,
      totalRatings: json['totalRatings'] as int? ?? 0,
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      acceptancePercentage: (json['acceptancePercentage'] ?? 0).toDouble(),
      totalEarnings: (json['totalEarnings'] ?? 0).toDouble(),
      earningsChart: (json['earningsChart'] as List<dynamic>?)
              ?.map((item) => EarningsChartData.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      recentActivities: (json['recentActivities'] as List<dynamic>?)
              ?.map((item) => DriverOrderModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class EarningsChartData {
  final String period;
  final double earnings;

  EarningsChartData({
    required this.period,
    required this.earnings,
  });

  factory EarningsChartData.fromJson(Map<String, dynamic> json) {
    return EarningsChartData(
      period: json['period']?.toString() ?? json['day']?.toString() ?? '',
      earnings: (json['earnings'] ?? json['amount'] ?? 0).toDouble(),
    );
  }
}
