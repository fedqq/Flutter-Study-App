import 'package:flutter/material.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:intl/intl.dart';
import 'package:studyappcs/pages/results_page.dart';
import 'package:studyappcs/state_managers/firestore_manager.dart';
import 'package:studyappcs/state_managers/tests_manager.dart';
import 'package:studyappcs/states/subject.dart';
import 'package:studyappcs/states/test.dart';
import 'package:studyappcs/widgets/test_input.dart';

class TestPage extends StatefulWidget {
  final List<TestCard> cards;
  final String testArea;
  final Subject? subject;
  const TestPage({super.key, required this.cards, required this.testArea, this.subject});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  late Test test;
  List<String> answers = [];

  @override
  void initState() {
    test = Test({for (TestCard card in widget.cards) card: false}, DateFormat.yMd().format(DateTime.now()),
        widget.testArea, answers, TestsManager.id);
    answers = [for (var _ in widget.cards) ''];
    super.initState();
  }

  void submitAnswers() {
    int i = 0;
    for (TestCard card in widget.cards) {
      if (ratio(answers[i], card.meaning) > 80) {
        test.scored[card] = true;
      }
      i++;
    }

    widget.subject?.addScore(test.percentage.toInt());

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultsPage(test: test..answers = answers),
      ),
    );
    TestsManager.addTest(test..answers = answers);

    var testDocs = FirestoreManager.testCollection;
    var doc = testDocs.doc();
    doc.set({'area': test.area, 'date': test.date});
    var collection = doc.collection('testcards');
    i = 0;
    for (var card in test.scored.keys) {
      collection.doc().set(
        {
          'name': card.name,
          'meaning': card.meaning,
          'given': answers[i],
          'origin': card.origin,
          'id': TestsManager.nextID,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    BorderRadius getRadius(int index) {
      Radius top = Radius.circular(index == 0 ? 12 : 3);
      Radius bottom = Radius.circular(index == widget.cards.length - 1 ? 12 : 3);

      return BorderRadius.only(topLeft: top, topRight: top, bottomLeft: bottom, bottomRight: bottom);
    }

    return Scaffold(
      appBar: AppBar(title: Text('Test on ${widget.testArea}'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            ListView.builder(
              itemCount: widget.cards.length,
              itemBuilder: (context, index) => TestInput(
                name: widget.cards[index].name,
                area: widget.cards[index].origin,
                onChanged: (str) => answers[index] = str,
                borderRadius: getRadius(index),
                padding: const EdgeInsets.all(2.0),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: FilledButton.tonal(onPressed: Navigator.of(context).pop, child: const Text('Cancel')),
            ),
            Positioned(
              width: (MediaQuery.of(context).size.width / 2) - 16,
              bottom: 0,
              right: 0,
              child: FilledButton(onPressed: submitAnswers, child: const Text('Submit Answers')),
            ),
          ],
        ),
      ),
    );
  }
}
