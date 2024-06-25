import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studyappcs/state_managers/statistics.dart' as stats;

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
    List<int> daysData = stats.getLastWeek();

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
    var [r, g, b] = [col.red, col.green, col.blue];

    double value = max(widget.animValue, 0.7);

    Color res = Color.fromARGB(
      255,
      255 - ((255 - r) * value).toInt(),
      255 - ((255 - g) * value).toInt(),
      255 - ((255 - b) * value).toInt(),
    );

    return LineChart(
      LineChartData(
        maxY: max(getMaxStudied() + 1, stats.dailyGoal + 1),
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
          ),),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            belowBarData: BarAreaData(
              gradient: LinearGradient(
                colors: [res, res.withAlpha(30)],
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
            spots: [FlSpot(0, stats.getAverage()), FlSpot(6, stats.getAverage())],
            color: Colors.grey,
            dashArray: [10],
            dotData: const FlDotData(show: false),
          ),
          LineChartBarData(
            spots: [FlSpot(0, stats.dailyGoal.toDouble()), FlSpot(6, stats.dailyGoal.toDouble())],
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}
