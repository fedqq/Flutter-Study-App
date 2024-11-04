import 'package:studyappcs/data_managers/firestore_manager.dart';
import 'package:studyappcs/states/test.dart';

//Stores all the past tests.
//This id is used to uniquely identify tests, and is stored in the server.
//Each test has a unique id.
int id = 0;

//Getter for the id, increments by 1 and returns the new value. This assures no duplicates.
int get nextID => id++;

void addTest(Test test) => pastTests.add(test);

bool hasScore(String s) => testsFromArea(s).isNotEmpty;

//Returns all tests from a specific area, such as 'Physics - Topic 1' or 'English'.
List<Test> testsFromArea(String area) {
  if (area == '') {
    return pastTests;
  }

  return area.contains('-')
      ? pastTests.where((element) => element.area == area).toList()
      : pastTests.where((element) => element.area.split('-')[0].trim() == area).toList();
}
