class TestCard {
  String meaning;
  String name;
  String origin;

  TestCard(this.name, this.meaning, this.origin);

  @override
  String toString() => '$name||$meaning||$origin';

  static TestCard fromString(String str) {
    List<String> data = str.split('||');

    return TestCard(data[0], data[1], data[2]);
  }
}

class Test {
  Map<TestCard, bool> scored;
  final String date;
  String area;
  List<String> answers;
  Test(this.scored, this.date, this.area, this.answers);

  int get percentage {
    return 100 * correct ~/ totalAmount;
  }

  int get correct {
    return scored.values.where((element) => element).length;
  }

  int get totalAmount {
    return scored.length;
  }
}
