class TestCard {
  TestCard(this.name, this.meaning, this.origin);
  String meaning;
  String name;
  String origin;
}

class Test {
  Test(this.scored, this.date, this.area, this.answers, this.id);
  Map<TestCard, bool> scored;
  final String date;
  String area;
  List<String> answers;
  final int id;

  int get percentage => 100 * correct ~/ totalAmount;

  int get correct => scored.values.where((bool element) => element).length;

  int get totalAmount => scored.length;
}
