// ignore: unused_import
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:studyappcs/data_managers/firestore_manager.dart' as firestore_manager;
import 'package:studyappcs/data_managers/tests_manager.dart' as tests_manager;
import 'package:studyappcs/pages/all_tests_page.dart';
import 'package:studyappcs/pages/test_page.dart';
import 'package:studyappcs/states/flashcard.dart';
import 'package:studyappcs/states/subject.dart';
import 'package:studyappcs/states/test.dart';
import 'package:studyappcs/states/topic.dart';
import 'package:studyappcs/utils/input_dialogs.dart';
import 'package:studyappcs/widgets/topic_card.dart';

class SubjectPage extends StatefulWidget {
  const SubjectPage({
    super.key,
    required this.subject,
  });
  final Subject subject;

  @override
  State<SubjectPage> createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage> {
  Future<void> newTopic() async {
    final topicName = await inputDialog(context, 'New Topic Name', Input(name: 'Name'));

    if (topicName == '') {
      return;
    }
    final topic = Topic(topicName)
      ..addCard(FlashCard('First Card', 'First Card Meaning', learned: false));
    final cardCollection = firestore_manager.cardCollection;
    await cardCollection.doc().set(<String, dynamic>{
      'name': 'First Card',
      'meaning': 'First Card Meaning',
      'learned': false,
      'subject': widget.subject.name,
      'topic': topic.name,
    });
    setState(() => widget.subject.addTopic(topic));
  }

  @override
  Widget build(BuildContext context) {
    final topicList = Expanded(
      child: ListView.builder(
        itemCount: widget.subject.topics.length,
        itemBuilder: (context, index) => TopicCard(
          topic: widget.subject.topics[index],
          area: '${widget.subject.name} - ${widget.subject.topics[index].name}',
          deleteTopic: () => setState(() => widget.subject.topics.removeAt(index)),
          testTopic: () => Navigator.push(
            context,
            // ignore: always_specify_types
            MaterialPageRoute(
              builder: (_) {
                final subject = widget.subject;
                final topic = subject.topics[index];

                final cards = List<TestCard>.generate(topic.cards.length, (i) {
                  final card = topic.cards[i];

                  return TestCard(card.name, card.meaning, '${widget.subject.name} - ${topic.name}');
                });

                return TestPage(
                  cards: cards,
                  testArea: '${subject.name} - ${topic.name}',
                  subject: subject,
                );
              },
            ),
          )..then((_) => setState(() {})),
          subject: widget.subject.name,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: widget.subject.name,
              child: Material(
                type: MaterialType.transparency,
                child: Text(widget.subject.name, style: Theme.of(context).textTheme.headlineSmall),
              ),
            ),
            Text(' Topics (${widget.subject.topics.length})', style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
        centerTitle: true,
        actions: [
          if (tests_manager.hasScore(widget.subject.asArea))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: FilledButton(
                child: const Text(
                  'Past tests',
                  textAlign: TextAlign.center,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    // ignore: always_specify_types
                    MaterialPageRoute(builder: (_) => AllTestsPage(area: widget.subject.name)),
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: newTopic,
        tooltip: 'New Topic',
        child: const Icon(Icons.add_rounded),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              children: [
                if (widget.subject.topics.isNotEmpty) topicList,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
