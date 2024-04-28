import "package:confirm_dialog/confirm_dialog.dart";
import "package:flutter/material.dart";
import "package:flutter_application_1/state_managers/statistics.dart";
import "package:flutter_application_1/states/flashcard.dart";
import "package:flutter_application_1/states/topic.dart";

// ignore: unused_import
import 'dart:developer' as developer;

import "package:flutter_application_1/utils.dart";
import "package:flutter_application_1/reused_widgets/gradient_widgets.dart";
import "package:flutter_application_1/reused_widgets/input_dialogs.dart";

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
    if (showingMeaning) {
      return card.meaning;
    } else {
      return card.name;
    }
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
      String newMeaning = await showInputDialog(context, 'New meaning for ${cards[currentCard].name}', 'Meaning',
              initialValue: cards[currentCard].meaning) ??
          '';
      if (newMeaning == '') return;
      setState(() {
        cards[currentCard].meaning = newMeaning;
      });
    } else {
      String newName = await showInputDialog(
            context,
            'Rename ${cards[currentCard].name}',
            'Name',
            initialValue: cards[currentCard].name,
          ) ??
          '';
      if (newName == '') return;
      setState(() {
        cards[currentCard].name = newName;
      });
    }
  }

  void deleteCard() async {
    bool delete = await confirm(context,
        title: Text('Are you sure you would like to delete ${cards[currentCard].name}?'),
        content: const Text('This action cannot be undone. '));
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
    String newName = await showInputDialog(context, 'Rename ${widget.topic.name}', 'Name') ?? '';
    if (newName == '') return;
    setState(() {
      widget.topic.name = newName;
      widget.renameCallback!(newName);
    });
  }

  Widget buildNavButton(double opacity, void Function() onPressed, String heroTag) {
    return AnimatedOpacity(
      duration: Durations.short1,
      opacity: opacity,
      child: GradientOutline(
        gradient: Theming.grayGradient,
        child: FloatingActionButton(
          heroTag: heroTag,
          onPressed: onPressed,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          hoverElevation: 0,
          child: const Icon(Icons.arrow_back_ios_rounded),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Row buttons = Row(children: [
      buildNavButton(currentCard == 0 ? 0.2 : 1, goBackward, 'backwardbtn'),
      const Spacer(),
      buildNavButton(currentCard == cards.length - 1 ? 0.2 : 1, goForward, 'forwardbtn'),
    ]);

    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              Center(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.renameCallback != null)
                    IconButton(icon: const Icon(Icons.edit_rounded), onPressed: editTopicName),
                  SizedBox(
                    height: 75,
                    child: Text(
                      widget.topic.name,
                      style: const TextStyle(fontSize: 35, height: 2),
                    ),
                  ),
                ],
              )),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 0, 20, 0),
                  child: InkWell(
                    hoverColor: Colors.transparent,
                    onTap: () {
                      setState(() => showingMeaning = !showingMeaning);
                      if (showingMeaning) {
                        if (Statistics.study()) {
                          simpleSnackBar(context, 'You reached you daily goal of ${Statistics.dailyGoal} terms!');
                        }
                      }
                    },
                    child: AnimatedContainer(
                      duration: Durations.long1,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: !cards[currentCard].learned
                                ? Theming.boxShadowColor
                                : const Color.fromARGB(80, 30, 253, 0),
                            spreadRadius: 0,
                            blurRadius: 20,
                          )
                        ],
                      ),
                      child: GradientOutline(
                          gradient: cards[currentCard].learned
                              ? Theming.gradientToDarker(const Color.fromARGB(80, 30, 253, 0))
                              : Theming.coloredGradient,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(45.0),
                              child: Text(
                                getCurrentText(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 25),
                              ),
                            ),
                          )),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: editCard,
                    icon: const Icon(Icons.mode_edit_rounded),
                  ),
                  SizedBox(
                    height: 75,
                    child: GradientOutline(
                      gradient: Theming.grayGradient,
                      child: FilledButton.tonal(
                        style: Theming.transparentButtonStyle,
                        onPressed: learnCard,
                        child: Text(cards[currentCard].learned ? 'Mark as unlearned' : 'Mark as learned',
                            style: const TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: deleteCard,
                    icon: const Icon(Icons.delete_forever_rounded),
                  ),
                ],
              ),
            ],
          ),
          Center(child: buttons),
        ],
      ),
    );
  }
}
