import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class _UserStatsResponse {
  final String period;
  final int count;
  final String label;

  _UserStatsResponse({
    required this.period,
    required this.count,
    required this.label,
  });

  factory _UserStatsResponse.fromJson(Map<String, dynamic> json) {
    return _UserStatsResponse(
      period: json['period'] as String,
      count: json['count'] as int,
      label: json['label'] as String,
    );
  }
}

class UserStatsChart extends StatefulWidget {
  const UserStatsChart({Key? key}) : super(key: key);

  @override
  _UserStatsChartState createState() => _UserStatsChartState();
}

class _UserStatsChartState extends State<UserStatsChart> {
  bool _isLoading = false;
  String _selectedFilter = 'month';
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  List<_UserStatsResponse> _statsData = [];
  String _error = '';

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null).then((_) => _fetchStats());
  }

  Future<void> _fetchStats() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final Map<String, String> queryParams = {
        'filter': _selectedFilter,
        'year': _selectedYear.toString(),
      };

      if (_selectedFilter == 'month') {
        queryParams['month'] = _selectedMonth.toString();
      }

      final response = await ApiService().request(
        method: 'GET',
        endpoint: '/users/statistics',
        withAuth: true,
        queryParams: queryParams,
      );

      if (!response.success) {
        throw Exception(response.error ?? 'Échec de la récupération des statistiques');
      }

      final List<dynamic> data = response.data as List<dynamic>;
      setState(() {
        _statsData = data
            .map((item) => _UserStatsResponse.fromJson(item as Map<String, dynamic>))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      debugPrint('Erreur lors de la récupération des statistiques: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Statistiques des inscriptions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildFilterControls(),
              ],
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_error.isNotEmpty)
              Center(
                child: Text(
                  'Erreur: $_error',
                  style: const TextStyle(color: Colors.red),
                ),
              )
            else if (_statsData.isEmpty)
              const Center(
                child: Text('Aucune donnée disponible pour cette période'),
              )
            else
              SizedBox(
                height: 300,
                child: LineChart(
                  LineChartData(
                    minY: 0,
                    gridData: const FlGridData(show: true),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            if (value == value.roundToDouble()) {
                              return Text(value.toInt().toString());
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= 0 && value.toInt() < _statsData.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  _statsData[value.toInt()].label,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _statsData.asMap().entries.map((entry) {
                          return FlSpot(entry.key.toDouble(), entry.value.count.toDouble());
                        }).toList(),
                        isCurved: true,
                        color: const Color(0xFF6C3FFE),
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: const Color(0xFF6C3FFE).withOpacity(0.2),
                        ),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                        tooltipBgColor: Colors.black87,
                        tooltipRoundedRadius: 8,
                        fitInsideHorizontally: true,
                        fitInsideVertically: true,
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((touchedSpot) {
                            final index = touchedSpot.x.toInt();
                            if (index >= 0 && index < _statsData.length) {
                              return LineTooltipItem(
                                '${_statsData[index].label}\n${_statsData[index].count} utilisateurs',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }
                            return null;
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterControls() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButton<String>(
          value: _selectedFilter,
          items: const [
            DropdownMenuItem(value: 'month', child: Text('Par mois')),
            DropdownMenuItem(value: 'year', child: Text('Par année')),
          ],
          onChanged: (value) {
            if (value != null && value != _selectedFilter) {
              setState(() {
                _selectedFilter = value;
              });
              _fetchStats();
            }
          },
        ),
        const SizedBox(width: 16),
        DropdownButton<int>(
          value: _selectedYear,
          items: List.generate(5, (index) {
            final year = DateTime.now().year - index;
            return DropdownMenuItem(value: year, child: Text(year.toString()));
          }),
          onChanged: (value) {
            if (value != null && value != _selectedYear) {
              setState(() {
                _selectedYear = value;
              });
              _fetchStats();
            }
          },
        ),
        if (_selectedFilter == 'month') ...[
          const SizedBox(width: 16),
          DropdownButton<int>(
            value: _selectedMonth,
            items: List.generate(12, (index) {
              return DropdownMenuItem(
                value: index + 1,
                child: Text(
                  DateFormat('MMMM', 'fr_FR')
                    .format(DateTime(2024, index + 1))
                    .capitalize(),
                ),
              );
            }),
            onChanged: (value) {
              if (value != null && value != _selectedMonth) {
                setState(() {
                  _selectedMonth = value;
                });
                _fetchStats();
              }
            },
          ),
        ],
      ],
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
