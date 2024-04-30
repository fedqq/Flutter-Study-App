import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Statistics {
  static Map<String, int> dailyStudied = {};
  static String userName = '';
  static int dailyGoal = 0;
  static String reminderTime = '';

  static void load() async {
    final prefs = await SharedPreferences.getInstance();
    dailyGoal = prefs.getInt('daily-goal') ?? 0;
    final List<String> unparsed = prefs.getStringList('studied-per-day') ?? [];
    for (String day in unparsed) {
      List<String> split = day.split('--');
      dailyStudied[split[0]] = int.parse(split[1]);
    }
    userName = prefs.getString('user-name') ?? '';

    reminderTime = prefs.getString('reminder-time') ?? '18:00';
  }

  static TimeOfDay getTime() {
    if (reminderTime == '') reminderTime = '18:00';

    return TimeOfDay(hour: int.parse(reminderTime.split(':')[0]), minute: int.parse(reminderTime.split(':')[1]));
  }

  static double getDailyGoal() => dailyGoal.toDouble();

  static void setTime(TimeOfDay time) {
    reminderTime = '${time.hour}:${NumberFormat('00').format(time.minute)}';
  }

  static void setDailyGoal(int goal) => dailyGoal = goal;

  static void save() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('daily-goal', dailyGoal);
    List<String> reparsed = [];
    for (String key in dailyStudied.keys) {
      reparsed.add('$key--${dailyStudied[key]}');
    }
    prefs.setStringList('studied-per-day', reparsed);
    prefs.setString('user-name', userName);
    prefs.setString('reminder-time', reminderTime);
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
      strs.add(DateFormat("EEEE, MMMM, yyyy", 'en-US').format(DateTime.now().add(Duration(days: -i))));
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

  static int getTodayStudied() => dailyStudied[getNowString()] ?? 0;

  static String getNowString() => DateFormat("EEEE, MMMM, yyyy", 'en-US').format(DateTime.now());
}
