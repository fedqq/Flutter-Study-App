// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/study_page.dart';
import 'package:flutter_application_1/states/flashcard.dart';
import 'package:flutter_application_1/states/topic.dart';
import 'package:flutter_application_1/utils.dart';

import 'dart:developer' as developer;

import 'package:flutter_application_1/widgets/gradient_widgets.dart';
import 'package:flutter_application_1/widgets/input_dialogs.dart';

class TopicCard extends StatefulWidget {
  final Topic topic;
  const TopicCard({super.key, required this.topic});

  @override
  State<TopicCard> createState() => _TopicCardState();
}

class _TopicCardState extends State<TopicCard> {
  void renameCallback(String newName) {
    setState(() {
      widget.topic.name = newName;
    });
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
              ))).then((_) => setState(() {}));

  void renameTopic(Topic topic) async {
    String newName = await showInputDialog(context, 'Rename ${topic.name}', 'Name') ?? '';
    if (newName == '') return;
    setState(() => topic.name = newName);
  }

  void addCard(Topic topic) async {
    DialogResult result =
        await showDoubleInputDialog(context, 'Create New Card', 'Name', 'Meaning', nullableSecond: false) ??
            emptyResult;

    String name = result.first;
    if (name == '') return;
    String meaning = result.second;
    if (meaning == '') return;
    setState(() => topic.cards.add(FlashCard(name, meaning, false)));
  }

  double learnedPercentage() {
    double ret = widget.topic.cards.isNotEmpty
        ? widget.topic.cards.where((element) => element.learned).length / widget.topic.cards.length
        : 0;
    developer.log(ret.toString());
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    Topic topic = widget.topic;
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Theming.boxShadowColor,
            blurRadius: 10,
            spreadRadius: -10,
          ),
        ],
      ),
      child: GradientOutline(
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
                      color: const Color.fromARGB(255, 51, 51, 51)),
                ),
                Container(
                  width: learnedPercentage() * 450,
                  height: 5,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Theming.radius), gradient: Theming.coloredGradient),
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
              width: 120,
              height: 40,
              child: Row(
                children: [
                  IconButton(
                      onPressed: () => topic.cards.isNotEmpty ? studyTopic(topic) : null,
                      icon: const Icon(Icons.school_rounded)),
                  IconButton(
                    onPressed: () => renameTopic(topic),
                    icon: const Icon(Icons.edit_rounded),
                  ),
                  IconButton(
                    onPressed: () => addCard(topic),
                    icon: const Icon(Icons.add_rounded),
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
                      contentPadding: const EdgeInsets.all(8.0),
                      title: Text(topic.cards[cardIndex].name),
                    )),
          ),
        ),
      ),
    );
  }
}
