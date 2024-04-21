import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Statistics {
  static Map<String, int> dailyStudied = {};
  static int dailyGoal = 0;

  static void load() async {
    final prefs = await SharedPreferences.getInstance();
    dailyGoal = prefs.getInt('daily-goal') ?? 0;
    final List<String> unparsed = prefs.getStringList('studied-per-day') ?? [];
    for (String day in unparsed) {
      List<String> split = day.split('--');
      dailyStudied[split[0]] = int.parse(split[1]);
    }
  }

  static void save() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('daily-goal', dailyGoal);
    List<String> reparsed = [];
    for (String key in dailyStudied.keys) {
      reparsed.add('$key--${dailyStudied[key]}');
    }
    prefs.setStringList('studied-per-day', reparsed);
  }

  static void study() async {
    String formatted = DateFormat("EEEE, MMMM, yyyy", 'en-US').format(DateTime.now());
    if (!dailyStudied.containsKey(formatted)) {
      dailyStudied[formatted] = 1;
      return;
    }
    dailyStudied[formatted] = dailyStudied[formatted]! + 1;
  }

  static void setDailyGoal(int goal) {
    dailyGoal = goal;
  }
}
