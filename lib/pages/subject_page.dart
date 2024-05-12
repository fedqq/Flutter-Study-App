import "package:flutter/material.dart";
import "package:flutter_application_1/pages/all_tests_page.dart";
import "package:flutter_application_1/pages/test_page.dart";
import "package:flutter_application_1/state_managers/tests_manager.dart";
import "package:flutter_application_1/states/flashcard.dart";
import "package:flutter_application_1/states/test.dart";
import "package:flutter_application_1/states/topic.dart";
import "package:flutter_application_1/states/subject.dart";
import "package:flutter_application_1/utils/input_dialogs.dart";
import "package:flutter_application_1/widgets/topic_card.dart";

// ignore: unused_import
import 'dart:developer' as developer;

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
    final String topicName = await singleInputDialog(context, 'New Topic Name', InputType(name: 'Name')) ?? '';

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
                List<TestCard> cards = List.generate(widget.subject.topics[index].cards.length, (i) {
                  FlashCard card = widget.subject.topics[index].cards[i];

                  return TestCard(
                    card.name,
                    card.meaning,
                    '${widget.subject.name} - ${widget.subject.topics[index].name}',
                  );
                });

                return TestPage(
                  cards: cards,
                  testArea: '${widget.subject.name} - ${widget.subject.topics[index].name}',
                  subject: widget.subject,
                );
              },
            ),
          )..then((_) => setState(() {})),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.subject.name} Topics (${widget.subject.topics.length})',
        ),
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
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AllTestsPage(area: widget.subject.name),
                      ),
                    ),
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
