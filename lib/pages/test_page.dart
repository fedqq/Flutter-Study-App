import 'package:flutter/material.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:intl/intl.dart';
import 'package:studyappcs/data_managers/firestore_manager.dart' as firestore_manager;
import 'package:studyappcs/data_managers/tests_manager.dart' as tests_manager;
import 'package:studyappcs/pages/results_page.dart';
import 'package:studyappcs/states/subject.dart';
import 'package:studyappcs/states/test.dart';
import 'package:studyappcs/utils/input_dialogs.dart';
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
    test = Test(
      {for (TestCard card in widget.cards) card: false},
      DateFormat.yMd().format(DateTime.now()),
      widget.testArea,
      answers,
      tests_manager.id,
    );
    answers = [for (var _ in widget.cards) ''];
    super.initState();
  }

  void submitAnswers() async {
    if (answers.where((a) => a == '').isNotEmpty) {
      if (!await confirmDialog(
        context,
        title: 'Some answers are empty. ',
      )) {
        return;
      }
    }

    int i = 0;
    for (TestCard card in widget.cards) {
      if (ratio(answers[i], card.meaning) > 80) {
        test.scored[card] = true;
      }
      i++;
    }

    widget.subject?.addScore(test.percentage.toInt());

    Navigator.pushReplacement(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(
        builder: (_) => ResultsPage(test: test..answers = answers),
      ),
    );
    tests_manager.addTest(test..answers = answers);

    var testDocs = firestore_manager.testCollection;
    var doc = testDocs.doc()
      ..set({
        'area': test.area,
        'date': test.date,
        'id': tests_manager.nextID,
      });
    var collection = doc.collection('testcards');
    i = 0;
    for (var card in test.scored.keys) {
      collection.doc().set(
        {
          'name': card.name,
          'meaning': card.meaning,
          'given': answers[i],
          'origin': card.origin,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    BorderRadius getRadius(int index) {
      if (index == 0) {}
      Radius top =
          Radius.circular(index == 0 ? 12 : (widget.cards[index - 1].origin == widget.cards[index].origin ? 12 : 3));
      Radius bottom = Radius.circular(
        index == widget.cards.length - 1 ? 12 : (widget.cards[index + 1].origin == widget.cards[index].origin ? 12 : 3),
      );

      return BorderRadius.only(topLeft: top, topRight: top, bottomLeft: bottom, bottomRight: bottom);
    }

    EdgeInsets getPadding(int index) {
      if (index == 0) {}
      double top = index == 0 ? 12 : (widget.cards[index - 1].origin == widget.cards[index].origin ? 12 : 3);
      double bottom = (index == widget.cards.length - 1
          ? 12
          : (widget.cards[index + 1].origin == widget.cards[index].origin ? 12 : 3));

      return EdgeInsets.only(top: top, bottom: bottom);
    }

    return Scaffold(
      appBar: AppBar(title: Text('Test on ${widget.testArea}'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ...List.generate(
              widget.cards.length,
              (index) => TestInput(
                name: widget.cards[index].name,
                area: widget.cards[index].origin,
                onChanged: (str) => answers[index] = str,
                borderRadius: getRadius(index),
                padding: getPadding(index),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FilledButton.tonal(onPressed: Navigator.of(context).pop, child: const Text('Cancel')),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FilledButton(onPressed: submitAnswers, child: const Text('Submit Answers')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
