import 'package:flutter_application_1/states/test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestsManager {
  static List<Test> pastTests = [];

  static void loadData() async {
    final prefs = await SharedPreferences.getInstance();
    for (String data in prefs.getStringList('past_tests') ?? []) {
      pastTests.add(Test.fromString(data));
    }
  }

  static void addTest(Test test) {
    pastTests.add(test);
  }

  static void saveData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> encoded = [];
    for (Test test in pastTests) {
      encoded.add(test.toString());
    }
    prefs.setStringList('past_tests', encoded);
  }
}
