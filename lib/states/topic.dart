import 'package:studyappcs/states/flashcard.dart';

class Topic {
  Topic(this.name);
  String name = '';
  List<FlashCard> cards = <FlashCard>[];

  void addCard(FlashCard card) {
    cards.add(card);
  }
}
