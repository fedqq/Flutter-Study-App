// ignore: unused_import
import 'dart:developer' as developer;

import "package:flutter/material.dart";
import "package:studyappcs/pages/all_tests_page.dart";
import "package:studyappcs/pages/test_page.dart";
import "package:studyappcs/state_managers/tests_manager.dart";
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
    Topic topic = Topic(topicName);

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
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.subject.name} Topics (${widget.subject.topics.length})'),
        centerTitle: true,
        actions: [
          if (TestsManager.hasScore(widget.subject.asArea))
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  FilledButton.tonal(
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
                ],
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
