// ignore: unused_import
import 'dart:developer' as developer;
import "dart:ui";

import "package:confirm_dialog/confirm_dialog.dart";
import "package:flutter/material.dart";
import "package:studyapp/state_managers/statistics.dart";
import "package:studyapp/states/flashcard.dart";
import "package:studyapp/states/topic.dart";
import "package:studyapp/utils/input_dialogs.dart";
import "package:studyapp/utils/snackbar.dart";

class StudyPage extends StatefulWidget {
  final List<FlashCard> cards;
  final Topic topic;
  final Function(String)? renameCallback;
  const StudyPage({super.key, required this.cards, required this.topic, this.renameCallback});

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

  void learnCard() => setState(() {
        cards[currentCard].learned = !cards[currentCard].learned;
      });

  void editCard() async {
    if (showingMeaning) {
      String newMeaning = await singleInputDialog(
            context,
            'New meaning for ${cards[currentCard].name}',
            Input(name: 'Meaning', initialValue: cards[currentCard].meaning),
          ) ??
          '';
      if (newMeaning == '') return;
      setState(() {
        cards[currentCard].meaning = newMeaning;
      });
    } else {
      String newName = await singleInputDialog(
            context,
            'Rename ${cards[currentCard].name}',
            Input(name: 'Name', initialValue: cards[currentCard].name),
          ) ??
          '';
      if (newName == '') return;
      setState(() {
        cards[currentCard].name = newName;
      });
    }
  }

  void deleteCard() async {
    bool delete = await confirm(
      context,
      title: Text('Are you sure you would like to delete ${cards[currentCard].name}?'),
      content: const Text('This action cannot be undone. '),
    );
    if (delete) {
      if (cards.length == 1) {
        widget.cards.removeAt(0);
        // ignore: use_build_context_synchronously
        Navigator.pop(context);

        return;
      }
      setState(() => widget.cards.removeAt(currentCard));
    }
  }

  void editTopicName() async {
    String newName = await singleInputDialog(context, 'Rename ${widget.topic.name}', Input(name: 'Name')) ?? '';
    if (newName == '') return;
    setState(() {
      widget.topic.name = newName;
      widget.renameCallback!(newName);
    });
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
                value: (StudyStatistics.dailyStudied[StudyStatistics.getNowString()] ?? 0) /
                    ((StudyStatistics.dailyGoal == 0) ? 20 : StudyStatistics.dailyGoal),
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
                    if (StudyStatistics.study()) {
                      simpleSnackBar(context, 'You reached you daily goal of ${StudyStatistics.dailyGoal} terms!');
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
                            onPressed: () {},
                          ),
                        ),
                        Center(
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
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
                          ]),
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
