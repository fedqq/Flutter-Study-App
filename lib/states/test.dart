class TestCard {
  String meaning;
  String name;
  String origin;

  TestCard(this.name, this.meaning, this.origin);
}

class Test {
  Map<TestCard, bool> cards;

  Test(this.cards);
}
