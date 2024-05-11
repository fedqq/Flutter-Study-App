import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/state_managers/statistics.dart';
import 'package:intl/intl.dart';

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

    Color col = Theme.of(context).colorScheme.inversePrimary;
    int r, g, b;
    [r, g, b] = [col.red, col.green, col.blue];

    double value = max(widget.animValue, 0.7);

    Color res = Color.fromARGB(
      255,
      255 - ((255 - r) * value).toInt(),
      255 - ((255 - g) * value).toInt(),
      255 - ((255 - b) * value).toInt(),
    );

    return LineChart(
      LineChartData(
        maxY: max(getMaxStudied() + 1, StudyStatistics.getDailyGoal() + 1),
        gridData: const FlGridData(verticalInterval: 1),
        titlesData: const FlTitlesData(
          show: false,
        ),
        backgroundColor: Colors.transparent,
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            belowBarData: BarAreaData(
              gradient: LinearGradient(
                colors: [
                  res,
                  res.withAlpha(30),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              show: true,
            ),
            color: res,
            barWidth: 5,
            isStrokeCapRound: true,
            isCurved: true,
            preventCurveOverShooting: true,
            dotData: const FlDotData(show: false),
            spots: List.generate(7, (i) => FlSpot(i.toDouble(), daysData[6 - i] * (min(widget.animValue, 0.8) + 0.2))),
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
