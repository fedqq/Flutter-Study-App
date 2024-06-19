class TestCard {
  String meaning;
  String name;
  String origin;

  TestCard(this.name, this.meaning, this.origin);
}

class Test {
  Map<TestCard, bool> scored;
  final String date;
  String area;
  List<String> answers;
  final int id;
  Test(this.scored, this.date, this.area, this.answers, this.id);

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
