import 'dart:developer' as developer;

class FlashCard {
  late String name;
  late String meaning;
  late bool learned;

  FlashCard(this.name, this.meaning, this.learned);

  @override
  String toString() => '$name<>$meaning<>${learned.toString()}';

  static FlashCard fromString(String str) {
    var split = str.split('<>');
    developer.log(split.toString());

    return FlashCard(split[0], split[1], bool.parse(split[2]));
  }
}
