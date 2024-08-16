// ignore_for_file: use_build_context_synchronously, always_specify_types

// ignore: unused_import
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:studyappcs/data_managers/firestore_manager.dart' as firestore_manager;
import 'package:studyappcs/data_managers/tests_manager.dart' as tests_manager;
import 'package:studyappcs/pages/all_tests_page.dart';
import 'package:studyappcs/pages/study_page.dart';
import 'package:studyappcs/states/flashcard.dart';
import 'package:studyappcs/states/topic.dart';
import 'package:studyappcs/utils/input_dialogs.dart';
import 'package:studyappcs/utils/utils.dart' as utils;

class TopicCard extends StatefulWidget {
  const TopicCard({
    super.key,
    required this.topic,
    required this.testTopic,
    required this.area,
    required this.subject,
    required this.deleteTopic,
  });
  final Topic topic;
  final Future<void> Function() testTopic;
  final String area;
  final String subject;
  final void Function() deleteTopic;

  @override
  State<TopicCard> createState() => _TopicCardState();
}

class _TopicCardState extends State<TopicCard> {
  bool checkExistingTerm(String name) {
    for (final card in widget.topic.cards) {
      if (card.name == name) {
        return false;
      }
    }

    return true;
  }

  void studyTopic(Topic topic) => Navigator.push(
        context,
        PageRouteBuilder(
          transitionsBuilder:
              (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
            const begin = Offset(0, 1);
            const end = Offset.zero;
            const curve = Curves.ease;

            final tween = Tween<Offset>(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          pageBuilder: (_, __, ___) => StudyPage(
            cards: topic.cards,
            topic: topic,
          ),
        ),
      ).then(
        (_) => setState(() {}),
      );

  Future<void> renameTopic(Topic topic) async {
    final oldName = topic.name;
    final newName = await inputDialog(
      context,
      'Rename ${topic.name}',
      Input(name: 'Name'),
    );
    if (newName != '') {
      setState(() {
        final subjectName = widget.area.split('-')[0].trim();
        topic.name = newName;
        final newArea = '$subjectName - $newName';
        for (final test in tests_manager.testsFromArea(widget.area)) {
          test.area = newArea;
        }
        widget.area.replaceAll(widget.area, newArea);
      });

      final cards = await firestore_manager.cardDocs;
      cards.docs
          .where((QueryDocumentSnapshot<utils.StrMap> a) => a['topic'] == oldName)
          .forEach((QueryDocumentSnapshot<utils.StrMap> a) => a.reference.update(<Object, Object?>{'topic': newName}));

      final tests = await firestore_manager.testDocs;
      tests.docs.where((QueryDocumentSnapshot<utils.StrMap> a) => (a['area'] as String).contains(oldName)).forEach(
            (QueryDocumentSnapshot<utils.StrMap> a) =>
                a.reference.update(<Object, Object?>{'area': (a['area'] as String).replaceAll(oldName, newName)}),
          );
    }
  }

  Future<void> deleteTopic(Topic topic) async {
    final oldName = topic.name;
    final confirmed = await confirmDialog(
      context,
      title: 'Delete $oldName',
    );
    if (confirmed) {
      final cards = await firestore_manager.cardDocs;
      cards.docs
          .where((QueryDocumentSnapshot<utils.StrMap> a) => a['topic'] == oldName)
          .forEach((QueryDocumentSnapshot<utils.StrMap> a) => a.reference.delete());

      final tests = await firestore_manager.testDocs;
      tests.docs
          .where((QueryDocumentSnapshot<utils.StrMap> a) => (a['area'] as String).contains(oldName))
          .forEach((QueryDocumentSnapshot<utils.StrMap> a) => a.reference.delete());

      widget.deleteTopic();
    }
  }

  Future<void> addCard(Topic topic) async {
    final result = await doubleInputDialog(
          context,
          'Create New Card',
          Input(name: 'Name', validate: checkExistingTerm),
          Input(name: 'Meaning'),
        ) ??
        DialogResult.empty;

    final name = result.first;
    if (name == '') {
      return;
    }
    final meaning = result.second;
    if (meaning != '') {
      setState(() => topic.cards.add(FlashCard(name, meaning, learned: false)));
    }
    final CollectionReference cardCollection = firestore_manager.cardCollection;
    await cardCollection.doc(name).set(<String, dynamic>{
      'name': name,
      'meaning': meaning,
      'subject': widget.subject,
      'topic': topic.name,
      'learned': false,
    });
  }

  double learnedPercentage() => widget.topic.cards.isNotEmpty
      ? widget.topic.cards.where((FlashCard element) => element.learned).length / widget.topic.cards.length
      : 0;

  @override
  Widget build(BuildContext context) {
    final topic = widget.topic;

    return Card(
      margin: const EdgeInsets.all(14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      elevation: 3,
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
                  borderRadius: BorderRadius.circular(20),
                  color: const Color.fromARGB(255, 51, 51, 51),
                ),
              ),
              Container(
                width: learnedPercentage() * 450,
                height: 5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          controlAffinity: ListTileControlAffinity.leading,
          shape: const Border(),
          onExpansionChanged: (bool expanded) => setState(() {
            final controller = ExpansionTileController.maybeOf(context);
            if (expanded) {
              controller?.collapse();
            } else {
              controller?.expand();
            }
          }),
          trailing: SizedBox(
            child: PopupMenuButton(
              itemBuilder: (BuildContext context) => <PopupMenuItem>[
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
                PopupMenuItem(
                  onTap: () => renameTopic(topic).then((_) => setState(() {})),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.edit_rounded),
                      Text('Rename Topic'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  onTap: () => deleteTopic(topic).then((_) => setState(() {})),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.delete_rounded),
                      Text('Delete Topic'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          title: Text(topic.name, textAlign: TextAlign.center),
          childrenPadding: EdgeInsets.zero,
          children: List.generate(
            topic.cards.length,
            (int cardIndex) => ListTile(
              minVerticalPadding: 0,
              contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 18),
              title: Text(topic.cards[cardIndex].name),
            ),
          )..insert(
              0,
              tests_manager.hasScore(widget.area)
                  ? TextButton(
                      onPressed: () =>
                          Navigator.push(context, MaterialPageRoute(builder: (_) => AllTestsPage(area: widget.area))),
                      child: Text(
                        'Your last score on this topic was ${tests_manager.testsFromArea(widget.area).last.percentage}%',
                      ),
                    )
                  : const SizedBox(),
            ),
        ),
      ),
    );
  }
}
