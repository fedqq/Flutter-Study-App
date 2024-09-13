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
  final VoidCallback deleteTopic;

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
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
      cards.docs.where((a) => a['topic'] == oldName).forEach((a) => a.reference.update({'topic': newName}));

      final tests = await firestore_manager.testDocs;
      tests.docs.where((a) => (a['area'] as String).contains(oldName)).forEach(
            (a) => a.reference.update({'area': (a['area'] as String).replaceAll(oldName, newName)}),
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
      cards.docs.where((a) => a['topic'] == oldName).forEach((a) => a.reference.delete());

      final tests = await firestore_manager.testDocs;
      tests.docs.where((a) => (a['area'] as String).contains(oldName)).forEach((a) => a.reference.delete());

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
    await cardCollection.doc().set({
      'name': name,
      'meaning': meaning,
      'subject': widget.subject,
      'topic': topic.name,
      'learned': false,
    });
  }

  PopupMenuItem menuItem({required VoidCallback onTap, required IconData icon, required String text}) => PopupMenuItem(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon),
            Text(text),
          ],
        ),
      );

  double learnedPercentage() => widget.topic.cards.isNotEmpty
      ? widget.topic.cards.where((element) => element.learned).length / widget.topic.cards.length
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
          visualDensity: VisualDensity.comfortable,
          subtitle: LinearProgressIndicator(
            borderRadius: BorderRadius.circular(10),
            minHeight: 8,
            value: learnedPercentage(),
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
              itemBuilder: (context) => <PopupMenuItem>[
                menuItem(
                  onTap: () => widget.testTopic().then((_) => setState(() {})),
                  icon: Icons.question_mark_rounded,
                  text: 'Test Topic',
                ),
                menuItem(
                  onTap: () => topic.cards.isNotEmpty ? studyTopic(topic) : null,
                  icon: Icons.school_rounded,
                  text: 'Open Cards',
                ),
                menuItem(
                  onTap: () => addCard(topic),
                  icon: Icons.add_rounded,
                  text: 'New Card',
                ),
                menuItem(
                  onTap: () => renameTopic(topic).then((_) => setState(() {})),
                  icon: Icons.edit_rounded,
                  text: 'Rename Topic',
                ),
                menuItem(
                  onTap: () => deleteTopic(topic).then((_) => setState(() {})),
                  icon: Icons.delete_rounded,
                  text: 'Delete Topic',
                ),
              ],
            ),
          ),
          title: Text(topic.name, textAlign: TextAlign.center),
          childrenPadding: EdgeInsets.zero,
          children: List.generate(
            topic.cards.length,
            (cardIndex) => ListTile(
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
