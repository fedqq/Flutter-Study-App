import 'package:sqflite/sqflite.dart';
import 'package:studyappcs/states/test.dart';

class TestsManager {
  static List<Test> pastTests = [];

  static Future<Database> getDatabase({required bool erase}) async {
    final path = await getDatabasesPath();
    if (erase) await databaseFactory.deleteDatabase('$path/tests.db');
    final database = openDatabase(
      '$path/tests.db',
      onCreate: (db, version) {
        db.execute('CREATE TABLE tests(resultsCode INT PRIMARY KEY, date TEXT, area TEXT)');
      },
      version: 1,
    );
    return await database;
  }

  static Future load() async {
    final db = await getDatabase(erase: false);
    final data = await db.rawQuery('SELECT * FROM tests');
    for (var entry in data) {
      Map<TestCard, bool> scored = {};
      List<String> answers = [];
      final results = await db.rawQuery('SELECT * FROM testResults${entry['resultsCode'] as int}');
      for (var result in results) {
        TestCard card = TestCard(result['name'] as String, result['meaning'] as String, result['origin'] as String);
        scored[card] = result['meaning'] == result['given'];
        answers.add(result['given'] as String);
      }
      Test test = Test(scored, entry['date'] as String, entry['area'] as String, answers);
      pastTests.add(test);
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
    final db = await getDatabase(erase: true);
    int current = 0;
    for (Test test in pastTests) {
      current += 1;
      await db.insert('tests', {
        'date': test.date,
        'area': test.area,
        'resultsCode': current,
      });
      await db
          .execute('CREATE TABLE testResults$current(name TEXT PRIMARY KEY, meaning TEXT, given TEXT, origin TEXT)');
      int i = 0;
      for (TestCard card in test.scored.keys) {
        String name = card.name;
        String correctAnswer = card.meaning;
        String givenAnswer = test.answers[i];
        await db.insert('testResults$current', {
          'name': name,
          'meaning': correctAnswer,
          'given': givenAnswer,
          'origin': card.origin,
        });
      }
    }
  }
}
