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
  Map<TestCard, bool> cards;
  final String date;
  final String area;
  Test(this.cards, this.date, this.area);

  @override
  String toString() {
    String res = '';
    cards.forEach(
      (key, value) {
        res += '${key.toString()};;${value.toString()}<>';
      },
    );

    res = res.substring(0, res.length - 2);

    return '$area[]$date[]$res';
  }

  static Test fromString(String str) {
    Map<TestCard, bool> result = {};
    String area;
    String date;
    String unsplit;
    [area, date, unsplit] = str.split('[]');
    List<String> data = unsplit.split('<>');
    for (String pair in data) {
      List<String> split = pair.split(';;');
      result[TestCard.fromString(split[0])] = bool.parse(split[1]);
    }

    return Test(result, date, area);
  }
}
