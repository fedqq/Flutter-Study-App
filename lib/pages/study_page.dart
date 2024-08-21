// ignore: unused_import
import 'dart:developer' as developer;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:studyappcs/data_managers/firestore_manager.dart' as firestore_manager;
import 'package:studyappcs/data_managers/user_data.dart' as user_data;
import 'package:studyappcs/states/flashcard.dart';
import 'package:studyappcs/states/topic.dart';
import 'package:studyappcs/utils/input_dialogs.dart';
import 'package:studyappcs/utils/utils.dart';

class StudyPage extends StatefulWidget {
  const StudyPage({super.key, required this.cards, required this.topic});
  final List<FlashCard> cards;
  final Topic topic;

  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
  int currentCardIndex = 0;
  bool showingMeaning = false;
  List<FlashCard> cards = <FlashCard>[];

  @override
  void initState() {
    cards = widget.cards;
    cards = widget.cards.where((card) => !card.learned).toList() +
        widget.cards.where((card) => card.learned).toList();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  FlashCard get currentCard => cards[currentCardIndex];

  void goForward() => setState(() {
        currentCardIndex++;
        wrapCurrentCard();
      });

  void goBackward() => setState(() {
        currentCardIndex--;
        wrapCurrentCard();
      });

  void wrapCurrentCard() {
    currentCardIndex = currentCardIndex % cards.length;
    showingMeaning = false;
  }

  Future<void> learnCard() async {
    final card = currentCard;

    final doc = await firestore_manager.cardNamed(card.name);

    await doc.reference.update(<Object, Object?>{'learned': !card.learned});

    setState(() => currentCard.learned = !currentCard.learned);
  }

  Future<void> editMeaning() async {
    final newMeaning = await inputDialog(
      context,
      'New meaning for ${currentCard.name}',
      Input(name: 'Meaning', value: currentCard.meaning),
    );
    if (newMeaning == '') {
      return;
    }
    setState(() => currentCard.meaning = newMeaning);
  }

  Future<void> editName() async {
    final newName = await inputDialog(
      context,
      'Rename ${currentCard.name}',
      Input(name: 'Name', value: currentCard.name),
    );
    if (newName == '') {
      return;
    }
    setState(() {
      currentCard.name = newName;
    });
  }

  Future<void> editCard() async {
    final oldName = currentCard.name;

    if (showingMeaning) {
      await editMeaning();
    } else {
      await editName();
    }

    final newName = currentCard.name;
    final newMeaning = currentCard.meaning;

    final doc = await firestore_manager.cardNamed(oldName);
    await doc.reference.update({'name': newName, 'meaning': newMeaning});
  }

  Future<void> deleteCard() async {
    if (cards.length == 1) {
      simpleSnackBar(context, 'Unable to delete card. Topics cannot have 0 cards');
      return;
    }
    final delete = await confirmDialog(
      context,
      title: 'Are you sure you would like to delete ${currentCard.name}?',
    );
    if (delete) {
      final doc = await firestore_manager.cardNamed(currentCard.name);
      await doc.reference.delete();

      setState(() => widget.cards.removeAt(currentCardIndex));
    }
  }

  Widget buildBar() => Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        height: 10,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: TweenAnimationBuilder<double>(
            duration: Durations.short4,
            tween: Tween(
              begin: 0,
              end: (user_data.dailyStudied[user_data.getNowString()] ?? 0) /
                  ((user_data.dailyGoal == 0) ? 20 : user_data.dailyGoal),
            ),
            builder: (_, value, ___) => LinearProgressIndicator(
              borderRadius: BorderRadius.circular(10),
              value: value,
            ),
          ),
        ),
      );

  Widget buildButtons() => Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton.filledTonal(
              onPressed: goBackward,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            FilledButton(
              onPressed: learnCard,
              child: Text(currentCard.learned ? 'Mark as unlearned' : 'Mark as learned'),
            ),
            IconButton.filledTonal(
              onPressed: goForward,
              icon: const Icon(Icons.arrow_forward_rounded),
            ),
          ],
        ),
      );

  Widget buildCard() => Expanded(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: InkWell(
            onTap: flipCard,
            child: DecoratedBox(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    blurRadius: 20,
                    spreadRadius: -5,
                    color: currentCard.learned ? const Color.fromARGB(55, 30, 253, 0) : Colors.transparent,
                  ),
                ],
              ),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                    Positioned(
                      left: 8,
                      top: 8,
                      child: IconButton(
                        icon: const Icon(Icons.delete_rounded),
                        onPressed: deleteCard,
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(currentCard.name, style: Theme.of(context).textTheme.headlineLarge),
                          ImageFiltered(
                            imageFilter: showingMeaning ? ImageFilter.dilate() : ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: Text(
                              currentCard.meaning,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ),
                        ].map((a) => Padding(padding: const EdgeInsets.all(8), child: a)).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  void flipCard() {
    setState(() => showingMeaning = !showingMeaning);
    if (showingMeaning && user_data.study()) {
      simpleSnackBar(context, 'You reached you daily goal of ${user_data.dailyGoal} terms!');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            buildBar(),
            buildCard(),
            buildButtons(),
          ],
        ),
      );
}
