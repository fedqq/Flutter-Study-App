import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/state_managers/statistics.dart';
import 'package:intl/intl.dart';

import '../utils/theming.dart';

class StudiedChart extends StatefulWidget {
  final double animValue;
  const StudiedChart({super.key, required this.animValue});

  @override
  State<StudiedChart> createState() => _StudiedChartState();
}

class _StudiedChartState extends State<StudiedChart> {
  List<String> getLastWeekNames() {
    List<String> strs = [];
    for (int i = 0; i < 7; i++) {
      strs.add(DateFormat("EEE", 'en-US').format(DateTime.now().add(Duration(days: 7 - i))));
    }

    return strs.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    List<int> daysData = StudyStatistics.getLastWeek();

    int getMaxStudied() {
      int max = 0;
      for (int i in daysData) {
        if (i > max) {
          max = i;
        }
      }

      return max;
    }

    return LineChart(
      LineChartData(
        maxY: max(getMaxStudied() + 1, StudyStatistics.getDailyGoal() + 1),
        gridData: const FlGridData(verticalInterval: 1),
        titlesData: const FlTitlesData(
          show: false,
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        lineBarsData: [
          LineChartBarData(
            belowBarData: BarAreaData(
              gradient: LinearGradient(
                colors: [Theming.blue.withAlpha(200), Theming.blue.withAlpha(30)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              show: true,
            ),
            color: Theming.blue,
            barWidth: 5,
            isStrokeCapRound: true,
            isCurved: true,
            preventCurveOverShooting: true,
            dotData: const FlDotData(show: false),
            spots: List.generate(7, (i) => FlSpot(i.toDouble(), daysData[6 - i].toDouble() * widget.animValue)),
          ),
          LineChartBarData(
            spots: [FlSpot(0, StudyStatistics.getAverage()), FlSpot(6, StudyStatistics.getAverage())],
            color: Colors.grey,
            dashArray: [10],
            dotData: const FlDotData(show: false),
          ),
          LineChartBarData(
            spots: [FlSpot(0, StudyStatistics.getDailyGoal()), FlSpot(6, StudyStatistics.getDailyGoal())],
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}
