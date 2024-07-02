// ignore: unused_import
import 'dart:developer' as developer;
import "dart:ui";

import "package:flutter/material.dart";
import "package:studyappcs/data_managers/firestore_manager.dart" as firestore_manager;
import "package:studyappcs/data_managers/user_data.dart" as user_data;
import "package:studyappcs/states/flashcard.dart";
import "package:studyappcs/states/topic.dart";
import "package:studyappcs/utils/input_dialogs.dart";
import "package:studyappcs/utils/utils.dart";

class StudyPage extends StatefulWidget {
  final List<FlashCard> cards;
  final Topic topic;
  const StudyPage({super.key, required this.cards, required this.topic});

  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
  int currentCard = 0;
  bool showingMeaning = false;
  List<FlashCard> cards = [];

  @override
  void initState() {
    cards = widget.cards.where((card) => !card.learned).toList() + widget.cards.where((card) => card.learned).toList();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String getCurrentText() {
    FlashCard card = cards[currentCard];

    return showingMeaning ? card.meaning : card.name;
  }

  void goForward() {
    setState(() {
      currentCard++;
      wrapCurrentCard();
    });
  }

  void goBackward() {
    setState(() {
      currentCard--;
      wrapCurrentCard();
    });
  }

  void wrapCurrentCard() {
    currentCard = currentCard % cards.length;
    showingMeaning = false;
  }

  void learnCard() async {
    var card = cards[currentCard];

    var doc = await firestore_manager.cardNamed(card.name);

    doc.reference.update({'learned': !card.learned});

    setState(() => cards[currentCard].learned = !cards[currentCard].learned);
  }

  void editCard() async {
    String oldName = cards[currentCard].name;

    if (showingMeaning) {
      String newMeaning = await singleInputDialog(
        context,
        'New meaning for ${cards[currentCard].name}',
        Input(name: 'Meaning', value: cards[currentCard].meaning),
      );
      if (newMeaning == '') return;
      setState(() => cards[currentCard].meaning = newMeaning);
    } else {
      String newName = await singleInputDialog(
        context,
        'Rename ${cards[currentCard].name}',
        Input(name: 'Name', value: cards[currentCard].name),
      );
      if (newName == '') return;
      setState(() {
        cards[currentCard].name = newName;
      });
    }

    String newName = cards[currentCard].name;
    String newMeaning = cards[currentCard].meaning;

    var doc = await firestore_manager.cardNamed(oldName);
    doc.reference.update({'name': newName, 'meaning': newMeaning});
  }

  void deleteCard() async {
    if (cards.length == 1) return;
    bool delete = await confirmDialog(
      context,
      title: 'Are you sure you would like to delete ${cards[currentCard].name}?',
    );
    if (delete) {
      var card = cards[currentCard];

      var doc = await firestore_manager.cardNamed(card.name);
      doc.reference.delete();

      setState(() => widget.cards.removeAt(currentCard));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            height: 5,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (user_data.dailyStudied[user_data.getNowString()] ?? 0) /
                    ((user_data.dailyGoal == 0) ? 20 : user_data.dailyGoal),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: InkWell(
                onTap: () {
                  setState(() => showingMeaning = !showingMeaning);
                  if (showingMeaning) {
                    if (user_data.study()) {
                      simpleSnackBar(context, 'You reached you daily goal of ${user_data.dailyGoal} terms!');
                    }
                  }
                },
                child: SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: cards[currentCard].learned ? const Color.fromARGB(80, 30, 253, 0) : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          right: 8,
                          top: 8,
                          child: IconButton(
                            icon: const Icon(Icons.edit_rounded),
                            onPressed: editCard,
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(cards[currentCard].name, style: Theme.of(context).textTheme.headlineLarge),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ImageFiltered(
                                  imageFilter:
                                      showingMeaning ? ImageFilter.dilate() : ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                  child: Text(
                                    cards[currentCard].meaning,
                                    style: Theme.of(context).textTheme.headlineLarge,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton.filledTonal(
                  onPressed: goBackward,
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                FilledButton(
                  onPressed: learnCard,
                  child: Text(cards[currentCard].learned ? 'Mark as unlearned' : 'Mark as learned'),
                ),
                IconButton.filledTonal(
                  onPressed: goForward,
                  icon: const Icon(Icons.arrow_forward_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
