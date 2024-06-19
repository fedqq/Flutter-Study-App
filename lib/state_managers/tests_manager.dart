import 'package:studyappcs/states/test.dart';

class TestsManager {
  static List<Test> pastTests = [];
  static int id = 0;

  static int get nextID {
    id++;
    return id;
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
}
