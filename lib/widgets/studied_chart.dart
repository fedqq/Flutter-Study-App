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
    final List<String> strs = <String>[];
    for (int i = 0; i < 7; i++) {
      strs.add(DateFormat('EEE', 'en-US').format(DateTime.now().add(Duration(days: 7 - i))));
    }

    return strs.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<int> daysData = user_data.getLastWeek();

    int getMaxStudied() {
      int max = 0;
      for (final int i in daysData) {
        if (i > max) {
          max = i;
        }
      }

      return max;
    }

    final Color col = Theme.of(context).colorScheme.inversePrimary;
    final [int r, int g, int b] = <int>[col.red, col.green, col.blue];

    final double value = max(widget.animValue, 0.7);

    final Color res = Color.fromARGB(
      255,
      255 - ((255 - r) * value).toInt(),
      255 - ((255 - g) * value).toInt(),
      255 - ((255 - b) * value).toInt(),
    );

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
              getTitlesWidget: (double value, TitleMeta meta) => Text(getLastWeekNames()[value.toInt()]),
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
            spots: List<FlSpot>.generate(7, (int i) => FlSpot(i.toDouble(), daysData[6 - i] * (min(widget.animValue, 0.8) + 0.2))),
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
