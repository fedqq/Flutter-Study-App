class FlashCard {
  late String name;
  late String meaning;
  late bool learned;
  late bool latex;

  FlashCard(this.name, this.meaning, this.learned, this.latex);

  @override
  String toString() => '$name<>$meaning<>${learned.toString()}<>${latex.toString()}';

  static FlashCard fromString(String str) {
    var split = str.split('<>');

    return FlashCard(split[0], split[1], bool.parse(split[2]), bool.parse(split[3]));
  }
}
