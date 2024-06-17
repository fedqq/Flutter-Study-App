import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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

  static Future load() async {
    final db = await getStatsBase();
    final data = await db.rawQuery('SELECT * FROM stats');
    if (data.isNotEmpty) {
      userName = data[0]['name'] as String;
      dailyGoal = data[0]['goal'] as int;
      lightness = (data[0]['lightness'] as int) == 0 ? false : true;
      color = Color(data[0]['color'] as int);
      updateTheme(() {});
    }

    dailyStreak = {};

    final streaks = await db.rawQuery('SELECT * FROM streaks');
    for (Map entry in streaks) {
      dailyStreak[entry['date'] as String] = entry['streak'] as int;
    }

    final studied = await db.rawQuery('SELECT * FROM studied');
    for (Map entry in studied) {
      dailyStreak[entry['date'] as String] = entry['studied'] as int;
    }
  }

  static Future<Database> getStatsBase() async {
    final path = await getDatabasesPath();
    final database = openDatabase(
      '$path/stats_db.db',
      onCreate: (db, version) {
        db.execute('CREATE TABLE stats(name TEXT, goal INT, code INT PRIMARY KEY, color INT, lightness INT)');
        db.execute('CREATE TABLE studied(date TEXT PRIMARY KEY, studied INT)');
        db.execute('CREATE TABLE streaks(date TEXT PRIMARY KEY, streak INT)');
      },
      version: 1,
    );
    return await database;
  }

  static double getDailyGoal() => dailyGoal.toDouble();

  static void setDailyGoal(int goal) => dailyGoal = goal;

  static void saveData() async {
    final db = await getStatsBase();

    await db.insert(
        'stats', {'name': userName, 'goal': dailyGoal, 'code': 1, 'color': color.value, 'lightness': lightness ? 1 : 0},
        conflictAlgorithm: ConflictAlgorithm.replace);

    dev.log(color.value.toString());

    dailyStreak.forEach((date, value) async => await db.insert(
          'streaks',
          {'date': date, 'streak': value},
          conflictAlgorithm: ConflictAlgorithm.replace,
        ));

    dailyStudied.forEach((date, value) async => await db.insert(
          'studied',
          {'date': date, 'studied': value},
          conflictAlgorithm: ConflictAlgorithm.replace,
        ));
  }

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
