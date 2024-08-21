import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studyappcs/data_managers/user_data.dart' as user_data;

class StudiedChart extends StatefulWidget {
  const StudiedChart({super.key, required this.animValue});
  final double animValue;

  @override
  State<StudiedChart> createState() => _StudiedChartState();
}

class _StudiedChartState extends State<StudiedChart> {
  List<String> getLastWeekNames() {
    final strs = <String>[];
    for (var i = 0; i < 7; i++) {
      strs.add(DateFormat('EEE', 'en-US').format(DateTime.now().add(Duration(days: 7 - i))));
    }

    return strs.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    final daysData = user_data.getLastWeek();

    int getMaxStudied() {
      var max = 0;
      for (final i in daysData) {
        if (i > max) {
          max = i;
        }
      }

      return max;
    }

    final col = Theme.of(context).colorScheme.inversePrimary;

    final double value = max(widget.animValue, 0.7);

    final res = Color.lerp(Colors.white, col, value) ?? Colors.white;

    return LineChart(
      LineChartData(
        maxY: max(getMaxStudied() + 1, user_data.dailyGoal + 1),
        gridData: const FlGridData(verticalInterval: 1),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          topTitles: const AxisTitles(),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              interval: 1,
              showTitles: true,
              reservedSize: 20,
              getTitlesWidget: (value, meta) => Text(getLastWeekNames()[value.toInt()]),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: <LineChartBarData>[
          LineChartBarData(
            belowBarData: BarAreaData(
              gradient: LinearGradient(
                colors: <Color>[res, res.withAlpha(30)],
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
            spots: List<FlSpot>.generate(
              7,
              (i) => FlSpot(i.toDouble(), daysData[6 - i] * (min(widget.animValue, 0.8) + 0.2)),
            ),
          ),
          LineChartBarData(
            spots: <FlSpot>[FlSpot(0, user_data.getAverage()), FlSpot(6, user_data.getAverage())],
            color: Colors.grey,
            dashArray: <int>[10],
            dotData: const FlDotData(show: false),
          ),
          LineChartBarData(
            spots: <FlSpot>[FlSpot(0, user_data.dailyGoal.toDouble()), FlSpot(6, user_data.dailyGoal.toDouble())],
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}
