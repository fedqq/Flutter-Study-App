import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyapp/states/test.dart';

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

  static bool hasScore(String s) => testsFromArea(s).isNotEmpty;

  static List<Test> testsFromArea(String area) {
    if (area == '') return pastTests;

    return area.contains('-')
        ? pastTests.where((element) => element.area == area).toList()
        : pastTests.where((element) => element.area.split('-')[0].trim() == area).toList();
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
