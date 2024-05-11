// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/all_tests_page.dart';
import 'package:flutter_application_1/pages/study_page.dart';
import 'package:flutter_application_1/state_managers/tests_manager.dart';
import 'package:flutter_application_1/states/flashcard.dart';
import 'package:flutter_application_1/states/test.dart';
import 'package:flutter_application_1/states/topic.dart';

// ignore: unused_import
import 'dart:developer' as developer;

import 'package:flutter_application_1/utils/input_dialogs.dart';

import '../utils/theming.dart';

class TopicCard extends StatefulWidget {
  final Topic topic;
  final Future Function() testTopic;
  final String area;
  const TopicCard({super.key, required this.topic, required this.testTopic, required this.area});

  @override
  State<TopicCard> createState() => _TopicCardState();
}

class _TopicCardState extends State<TopicCard> {
  void renameCallback(String newName) {
    setState(() {
      widget.topic.name = newName;
    });
  }

  bool checkExistingTerm(String name) {
    for (FlashCard card in widget.topic.cards) {
      if (card.name == name) {
        return false;
      }
    }

    return true;
  }

  void studyTopic(Topic topic) => Navigator.push(
        context,
        PageRouteBuilder(
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            Animatable<Offset> tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          pageBuilder: (_, __, ___) => StudyPage(
            cards: topic.cards,
            topic: topic,
            renameCallback: renameCallback,
          ),
        ),
      ).then((_) => setState(() {
            return;
          }));

  void renameTopic(Topic topic) async {
    String newName = await singleInputDialog(
          context,
          'Rename ${topic.name}',
          InputType(name: 'Name'),
        ) ??
        '';
    if (newName != '') {
      setState(() {
        String subjectName = widget.area.split('-')[0].trim();
        topic.name = newName;
        String newArea = '$subjectName - $newName';
        for (Test test in TestsManager.testsFromArea(widget.area)) {
          test.area = newArea;
        }
        widget.area.replaceAll(widget.area, newArea);
      });
    }
  }

  void addCard(Topic topic) async {
    DialogResult result = await doubleInputDialog(
          context,
          'Create New Card',
          InputType(name: 'Name', validate: checkExistingTerm),
          InputType(name: 'Meaning', nullable: false, latex: true),
          cancellable: true,
        ) ??
        DialogResult.empty();

    String name = result.first;
    if (name == '') return;
    String meaning = result.second;
    if (meaning != '') setState(() => topic.cards.add(FlashCard(name, meaning, false)));
  }

  double learnedPercentage() => widget.topic.cards.isNotEmpty
      ? widget.topic.cards.where((element) => element.learned).length / widget.topic.cards.length
      : 0;

  @override
  Widget build(BuildContext context) {
    Topic topic = widget.topic;

    return Card(
      margin: const EdgeInsets.all(14.0),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(25))),
      shadowColor: Colors.transparent,
      child: ListTileTheme(
        contentPadding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
        minLeadingWidth: 10,
        child: ExpansionTile(
          subtitle: Stack(
            children: [
              Container(
                width: 450,
                height: 5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Theming.radius),
                  color: const Color.fromARGB(255, 51, 51, 51),
                ),
              ),
              Container(
                width: learnedPercentage() * 450,
                height: 5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Theming.radius),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          controlAffinity: ListTileControlAffinity.leading,
          shape: const Border(),
          onExpansionChanged: (expanded) => setState(() {
            final controller = ExpansionTileController.maybeOf(context);
            if (expanded) {
              controller?.collapse();
            } else {
              controller?.expand();
            }
          }),
          trailing: SizedBox(
            child: PopupMenuButton(
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  onTap: () => widget.testTopic().then((_) => setState(() {})),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.question_mark_rounded),
                      Text('Test on topic'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  onTap: () => topic.cards.isNotEmpty ? studyTopic(topic) : null,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.school_rounded),
                      Text('Open cards'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  onTap: () => addCard(topic),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.add_rounded),
                      Text('New card'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          title: Text(
            topic.name,
            textAlign: TextAlign.center,
          ),
          childrenPadding: const EdgeInsets.all(0),
          children: List.generate(
            topic.cards.length,
            (cardIndex) => ListTile(
              minVerticalPadding: 0,
              contentPadding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 18),
              title: Text(topic.cards[cardIndex].name),
            ),
          )..insert(
              0,
              TestsManager.hasScore(widget.area)
                  ? TextButton(
                      onPressed: () =>
                          Navigator.push(context, MaterialPageRoute(builder: (_) => AllTestsPage(area: widget.area))),
                      child: Text(
                        'Your last score on this topic was ${TestsManager.testsFromArea(widget.area).last.percentage}%',
                      ),
                    )
                  : const SizedBox(),
            ),
        ),
      ),
    );
  }
}
