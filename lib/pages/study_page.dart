import "package:confirm_dialog/confirm_dialog.dart";
import "package:flutter/material.dart";
import "package:flutter_application_1/state_managers/statistics.dart";
import "package:flutter_application_1/states/flashcard.dart";
import "package:flutter_application_1/states/topic.dart";

// ignore: unused_import
import 'dart:developer' as developer;

import "package:flutter_application_1/utils/snackbar.dart";
import "package:flutter_application_1/utils/input_dialogs.dart";
import "package:latext/latext.dart";

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
            InputType(name: 'Meaning', initialValue: cards[currentCard].meaning),
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
            InputType(name: 'Name', initialValue: cards[currentCard].name),
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
    String newName = await singleInputDialog(context, 'Rename ${widget.topic.name}', InputType(name: 'Name')) ?? '';
    if (newName == '') return;
    setState(() {
      widget.topic.name = newName;
      widget.renameCallback!(newName);
    });
  }

  Widget buildNavButton(double opacity, void Function() onPressed, String heroTag, {bool forward = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: AnimatedOpacity(
        opacity: opacity,
        duration: Durations.short1,
        child: IconButton.filledTonal(
          onPressed: onPressed,
          style: const ButtonStyle(
            padding: MaterialStatePropertyAll(EdgeInsets.all(13.0)),
            shape: MaterialStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            ),
          ),
          icon: Icon(forward ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_rounded),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Row buttons = Row(children: [
      buildNavButton(currentCard == 0 ? 0.2 : 1, goBackward, 'backwardbtn'),
      const Spacer(),
      buildNavButton(currentCard == cards.length - 1 ? 0.2 : 1, goForward, 'forwardbtn', forward: true),
    ]);

    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          Positioned.fill(
            top: 0,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  height: 5,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    child: LinearProgressIndicator(
                      value: (StudyStatistics.dailyStudied[StudyStatistics.getNowString()] ?? 0) /
                          ((StudyStatistics.dailyGoal == 0) ? 20 : StudyStatistics.dailyGoal),
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 10),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: widget.renameCallback != null ? editTopicName : null,
                      child: SizedBox(
                        height: 75,
                        child: Text(
                          widget.topic.name,
                          style: const TextStyle(fontSize: 35, height: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 0, 20, 0),
                  child: InkWell(
                    hoverColor: Colors.transparent,
                    onTap: () {
                      setState(() => showingMeaning = !showingMeaning);
                      if (showingMeaning) {
                        if (StudyStatistics.study()) {
                          simpleSnackBar(context, 'You reached you daily goal of ${StudyStatistics.dailyGoal} terms!');
                        }
                      }
                    },
                    child: AnimatedContainer(
                      duration: Durations.long1,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: cards[currentCard].learned
                                ? const Color.fromARGB(80, 30, 253, 0)
                                : Theme.of(context).colorScheme.primaryContainer,
                            width: 5,
                          ),
                          borderRadius: const BorderRadius.all(Radius.circular(35)),
                        ),
                        elevation: 1,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(45.0),
                            child: LaTexT(
                              laTeXCode: Text(
                                getCurrentText(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 25),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: editCard,
                      icon: const Icon(Icons.mode_edit_rounded),
                    ),
                    FilledButton(
                      onPressed: learnCard,
                      child: Text(cards[currentCard].learned ? 'Mark as unlearned' : 'Mark as learned'),
                    ),
                    IconButton(
                      onPressed: deleteCard,
                      icon: const Icon(Icons.delete_forever_rounded),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Center(child: buttons),
        ],
      ),
    );
  }
}
