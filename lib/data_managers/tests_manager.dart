import 'package:studyappcs/states/test.dart';

List<Test> pastTests = <Test>[];
int id = 0;

int get nextID => id++;

void addTest(Test test) {
  pastTests.add(test);
}

bool hasScore(String s) => testsFromArea(s).isNotEmpty;

List<Test> testsFromArea(String area) {
  if (area == '') {
    return pastTests;
  }

  return area.contains('-')
      ? pastTests.where((element) => element.area == area).toList()
      : pastTests.where((element) => element.area.split('-')[0].trim() == area).toList();
}
