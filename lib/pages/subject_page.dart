// ignore: unused_import
import 'dart:developer' as developer;

import "package:flutter/material.dart";
import "package:studyappcs/data_managers/firestore_manager.dart" as firestore_manager;
import "package:studyappcs/data_managers/tests_manager.dart" as tests_manager;
import "package:studyappcs/pages/all_tests_page.dart";
import "package:studyappcs/pages/test_page.dart";
import "package:studyappcs/states/flashcard.dart";
import "package:studyappcs/states/subject.dart";
import "package:studyappcs/states/test.dart";
import "package:studyappcs/states/topic.dart";
import "package:studyappcs/utils/input_dialogs.dart";
import "package:studyappcs/widgets/topic_card.dart";

class SubjectPage extends StatefulWidget {
  final Subject subject;
  const SubjectPage({
    super.key,
    required this.subject,
  });

  @override
  State<SubjectPage> createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage> {
  void newTopic() async {
    final String topicName = await singleInputDialog(context, 'New Topic Name', Input(name: 'Name'));

    if (topicName == '') return;
    Topic topic = Topic(topicName)..addCard(FlashCard('First Card', 'First Card Meaning', learned: false));
    var cardCollection = firestore_manager.cardCollection;
    cardCollection.doc('First Card').set({
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
    Expanded topicList = Expanded(
      child: ListView.builder(
        itemCount: widget.subject.topics.length,
        itemBuilder: (context, index) => TopicCard(
          topic: widget.subject.topics[index],
          area: '${widget.subject.name} - ${widget.subject.topics[index].name}',
          deleteTopic: () => setState(() => widget.subject.topics.removeAt(index)),
          testTopic: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) {
                Subject subject = widget.subject;
                Topic topic = subject.topics[index];

                List<TestCard> cards = List.generate(topic.cards.length, (i) {
                  FlashCard card = topic.cards[i];

                  return TestCard(card.name, card.meaning, '${widget.subject.name} - ${topic.name}');
                });

                return TestPage(cards: cards, testArea: '${subject.name} - ${topic.name}', subject: subject);
              },
            ),
          )..then((_) => setState(() {})),
          subject: widget.subject.name,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.subject.name} Topics (${widget.subject.topics.length})'),
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
