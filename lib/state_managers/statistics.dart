import 'dart:math';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudyStatistics {
  static Map<String, int> dailyStudied = {};
  static Map<String, int> dailyStreak = {};
  static String userName = '';
  static int dailyGoal = 0;
  static int streak = 0;

  static int calculateStreak() {
    if ((dailyStudied[getNowString()] ?? 0) < dailyGoal) return 0;

    int lastStreak = dailyStreak[format(DateTime.now().add(const Duration(days: -1)))] ?? 0;

    return lastStreak + 1;
  }

  static void load() async {
    final prefs = await SharedPreferences.getInstance();
    dailyGoal = prefs.getInt('daily-goal') ?? 20;
    final List<String> unparsed = prefs.getStringList('studied-per-day') ?? [];
    for (String day in unparsed) {
      List<String> split = day.split('--');
      dailyStudied[split[0]] = int.parse(split[1]);
    }
    userName = prefs.getString('user-name') ?? '';
  }

  static double getDailyGoal() => dailyGoal.toDouble();

  static void setDailyGoal(int goal) => dailyGoal = goal;

  static void saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('daily-goal', dailyGoal);
    List<String> reparsed = [];
    for (String key in dailyStudied.keys) {
      reparsed.add('$key--${dailyStudied[key]}');
    }

    dailyStreak[getNowString()] = calculateStreak();

    List<String> reparsedStreak = [];
    for (String key in dailyStreak.keys) {
      reparsedStreak.add('$key--${dailyStreak[key]}');
    }

    prefs.setStringList('studied-per-day', reparsed);
    prefs.setStringList('streak-per-day', reparsedStreak);
    prefs.setString('user-name', userName);
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

  static String format(DateTime date) => DateFormat("EEEE, MMMM, yyyy", 'en-US').format(date);

  static int getTodayStudied() => dailyStudied[getNowString()] ?? 0;

  static String getNowString() => format(DateTime.now());
}
