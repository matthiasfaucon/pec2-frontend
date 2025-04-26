import 'package:flutter/material.dart';
import '../services/api_service.dart';

class UserStatsResponse {
  final String period;
  final int count;
  final String label;

  UserStatsResponse({
    required this.period,
    required this.count,
    required this.label,
  });

  factory UserStatsResponse.fromJson(Map<String, dynamic> json) {
    return UserStatsResponse(
      period: json['period'] as String,
      count: json['count'] as int,
      label: json['label'] as String,
    );
  }
}

class StatsService {
  static final StatsService _instance = StatsService._internal();
  factory StatsService() => _instance;
  StatsService._internal();

  Future<List<UserStatsResponse>> getUserStats({
    required String filter,
    int? year,
    int? month,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'filter': filter,
      };

      if (year != null) {
        queryParams['year'] = year.toString();
      }

      if (month != null) {
        queryParams['month'] = month.toString();
      }

      final response = await ApiService().request(
        method: 'GET',
        endpoint: '/users/statistics',
        withAuth: true,
        queryParams: queryParams,
      );

      if (!response.success) {
        throw Exception(response.error ?? 'Failed to fetch statistics');
      }

      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((item) => UserStatsResponse.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching user statistics: $e');
      rethrow;
    }
  }
} 