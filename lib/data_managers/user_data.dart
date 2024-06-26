import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Map<String, int> dailyStudied = {};
Map<String, int> dailyStreak = {};
String userName = '';
int _dailyGoal = 0;
int streak = 0;
bool _light = false;
Color _accentColor = Colors.blue;
late void Function(void Function()) updateTheme;

int calculateStreak() {
  if ((dailyStudied[getNowString()] ?? 0) < _dailyGoal) return 0;

  int lastStreak = dailyStreak[format(DateTime.now().add(const Duration(days: -1)))] ?? 0;

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
  int highest = 0;
  dailyStreak.forEach((_, value) => highest = max(highest, value));

  return highest;
}

bool study() {
  String formatted = getNowString();
  if (!dailyStudied.containsKey(formatted)) {
    dailyStudied[formatted] = 1;
  } else {
    dailyStudied[formatted] = dailyStudied[formatted]! + 1;
  }

  return ((dailyStudied[formatted] ?? 0) == _dailyGoal);
}

List<int> getLastWeek() {
  List<String> strs = [];
  for (int i = 0; i < 7; i++) {
    strs.add(format(DateTime.now().add(Duration(days: -i))));
  }
  List<int> res = [];
  for (String date in strs) {
    int num = dailyStudied[date] ?? 0;
    res.add(num);
  }

  return res;
}

double getAverage() {
  int sum = 0;
  for (int i in getLastWeek()) {
    sum += i;
  }

  return sum / 7;
}

String format(DateTime date) => DateFormat.yMd().format(date);

int getTodayStudied() => dailyStudied[getNowString()] ?? 0;

String getNowString() => format(DateTime.now());
