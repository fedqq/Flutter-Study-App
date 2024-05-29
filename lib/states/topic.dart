import "package:studyapp/states/flashcard.dart";

class Topic {
  String name = '';
  List<FlashCard> cards = [];

  Topic(this.name);

  void addCard(card) {
    cards.add(card);
  }

  @override
  String toString() {
    String cardData = '';
    for (FlashCard card in cards) {
      cardData += '${card.toString()};';
    }

    if (cardData.isNotEmpty) cardData = cardData.substring(0, cardData.length - 1);

    return '$name|$cardData';
  }

  static Topic fromString(String str) {
    List<String> split = str.split("|");

    String name = split[0];
    Topic finalTopic = Topic(name);
    if (split.length != 1) {
      List<String> cards = split[1].split(';');
      for (String cardString in cards) {
        if (cardString != '') finalTopic.addCard(FlashCard.fromString(cardString));
      }
    }

    return finalTopic;
  }
}
