import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Map<String, int> dailyStudied = <String, int>{};
Map<String, int> dailyStreak = <String, int>{};
String userName = '';
int _dailyGoal = 0;
int streak = 0;
bool _light = false;
Color _accentColor = Colors.blue;
late void Function(VoidCallback) updateTheme;

int calculateStreak() {
  if ((dailyStudied[getTodayString()] ?? 0) < _dailyGoal) {
    return 0;
  }

  final lastStreak = dailyStreak[format(DateTime.now().add(const Duration(days: -1)))] ?? 0;

  return lastStreak + 1;
}

// ignore: avoid_positional_boolean_parameters
set lightness(bool b) {
  _light = b;
  updateTheme(() {});
}

bool get lightness => _light;

set color(Color color) {
  _accentColor = color;
  updateTheme(() {});
}

Color get color => _accentColor;

int get dailyGoal => _dailyGoal;

set dailyGoal(int goal) => _dailyGoal = goal;

int get maxStreak {
  var highest = 0;
  dailyStreak.forEach((_, value) => highest = max(highest, value));

  return highest;
}

//Called whenever a card is flipped. Increments the daily value.
//Returns whether the goal is reached.
bool study() {
  final formatted = getTodayString();
  if (!dailyStudied.containsKey(formatted)) {
    dailyStudied[formatted] = 1;
  } else {
    dailyStudied[formatted] = dailyStudied[formatted]! + 1;
  }

  return ((dailyStudied[formatted] ?? 0) == _dailyGoal);
}

//Returns the last week of daily cards studied.
List<int> getLastWeek() {
  final strs = <String>[];
  for (var i = 0; i < 7; i++) {
    strs.add(format(DateTime.now().add(Duration(days: -i))));
  }
  final res = <int>[];
  for (final date in strs) {
    final num = dailyStudied[date] ?? 0;
    res.add(num);
  }

  return res;
}

double getWeeklyAverage() {
  var sum = 0;
  for (final i in getLastWeek()) {
    sum += i;
  }

  return sum / 7;
}

String format(DateTime date) => DateFormat.yMd().format(date);

int studiedTodayCount() => dailyStudied[getTodayString()] ?? 0;

String getTodayString() => format(DateTime.now());
