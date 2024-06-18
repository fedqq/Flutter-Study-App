import "package:studyappcs/states/flashcard.dart";

class Topic {
  String name = '';
  List<FlashCard> cards = [];

  Topic(this.name);

  void addCard(FlashCard card) {
    cards.add(card);
  }
}
