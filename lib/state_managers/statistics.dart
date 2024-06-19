import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StudyStatistics {
  static Map<String, int> dailyStudied = {};
  static Map<String, int> dailyStreak = {};
  static String userName = '';
  static int dailyGoal = 0;
  static int streak = 0;
  static bool _light = false;
  static Color _accentColor = Colors.blue;
  static late void Function(void Function()) updateTheme;

  static int calculateStreak() {
    if ((dailyStudied[getNowString()] ?? 0) < dailyGoal) return 0;

    int lastStreak = dailyStreak[format(DateTime.now().add(const Duration(days: -1)))] ?? 0;

    return lastStreak + 1;
  }

  static set lightness(bool b) {
    _light = b;
    updateTheme(() {});
  }

  static bool get lightness => _light;

  static set color(Color color) {
    _accentColor = color;
    updateTheme(() {});
  }

  static Color get color => _accentColor;

  static double getDailyGoal() => dailyGoal.toDouble();

  static void setDailyGoal(int goal) => dailyGoal = goal;

  static int get maxStreak {
    int highest = 0;
    dailyStreak.forEach((_, value) => highest = max(highest, value));

    return highest;
  }

  static bool study() {
    String formatted = getNowString();
    if (!dailyStudied.containsKey(formatted)) {
      dailyStudied[formatted] = 1;
    } else {
      dailyStudied[formatted] = dailyStudied[formatted]! + 1;
    }

    return ((dailyStudied[formatted] ?? 0) == dailyGoal);
  }

  static List<int> getLastWeek() {
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

  static double getAverage() {
    int sum = 0;
    for (int i in getLastWeek()) {
      sum += i;
    }

    return sum / 7;
  }

  static String format(DateTime date) => DateFormat.yMd().format(date);

  static int getTodayStudied() => dailyStudied[getNowString()] ?? 0;

  static String getNowString() => format(DateTime.now());
}
