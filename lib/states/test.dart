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
  Map<TestCard, bool> cardCorrect;
  final String date;
  String area;
  List<String> answers;
  Test(this.cardCorrect, this.date, this.area, this.answers);

  @override
  String toString() {
    String res = '';
    cardCorrect.forEach(
      (key, value) {
        res += '${key.toString()};;${value.toString()}<>';
      },
    );

    res = res.substring(0, res.length - 2);

    String ans = '';
    for (String a in answers) {
      ans += '$a||';
    }

    ans = ans.substring(0, ans.length - 2);

    return '$area[]$date[]$res[]$ans';
  }

  int get percentage {
    return 100 * correct ~/ totalAmount;
  }

  int get correct {
    return cardCorrect.values.where((element) => element).length;
  }

  int get totalAmount {
    return cardCorrect.length;
  }

  static Test fromString(String str) {
    Map<TestCard, bool> result = {};
    String area;
    String date;
    String unsplit;
    String answers;
    [area, date, unsplit, answers] = str.split('[]');

    List<String> data = unsplit.split('<>');
    for (String pair in data) {
      List<String> split = pair.split(';;');
      result[TestCard.fromString(split[0])] = bool.parse(split[1]);
    }

    return Test(result, date, area, answers.split('||'));
  }
}
