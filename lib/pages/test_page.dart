import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studyappcs/data_managers/firestore_manager.dart' as firestore_manager;
import 'package:studyappcs/data_managers/tests_manager.dart' as tests_manager;
import 'package:studyappcs/pages/results_page.dart';
import 'package:studyappcs/states/subject.dart';
import 'package:studyappcs/states/test.dart';
import 'package:studyappcs/utils/input_dialogs.dart';
import 'package:studyappcs/widgets/test_input.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key, required this.cards, required this.testArea, this.subject});
  final List<TestCard> cards;
  final String testArea;
  final Subject? subject;

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  late Test test;
  List<String> answers = <String>[];

  @override
  void initState() {
    test = Test(
      {for (final TestCard card in widget.cards) card: false},
      DateFormat.yMd().format(DateTime.now()),
      widget.testArea,
      answers,
      tests_manager.nextID,
    );
    answers = <String>[for (final TestCard _ in widget.cards) ''];
    super.initState();
  }

  Future<void> submitAnswers() async {
    if (answers.where((a) => a == '').isNotEmpty) {
      if (!await confirmDialog(
        context,
        title: 'Some answers are empty. ',
      )) {
        return;
      }
    }

    var i = 0;
    for (final card in widget.cards) {
      if (answers[i] == card.meaning) {
        test.scored[card] = true;
      }
      i++;
    }

    widget.subject?.addScore(test.percentage);

    await Navigator.pushReplacement(
      // ignore: use_build_context_synchronously
      context,
      // ignore: always_specify_types
      MaterialPageRoute(
        builder: (_) => ResultsPage(test: test..answers = answers),
      ),
    );
    tests_manager.addTest(test..answers = answers);

    final testDocs = firestore_manager.testCollection;
    final doc = testDocs.doc();
    await doc.set({
      'area': test.area,
      'date': test.date,
      'id': tests_manager.nextID,
    });
    final collection = doc.collection('testcards');
    i = 0;
    for (final card in test.scored.keys) {
      await collection.doc().set(
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
      final origin = widget.cards[index].origin;
      var top = 12.0;
      if (index != 0 && widget.cards[index - 1].origin != origin) {
        top = 3;
      }

      var bottom = 12.0;

      if (index != 0 &&
          index != widget.cards.length - 1 &&
          widget.cards[index - 1].origin == origin &&
          widget.cards[index + 1].origin != origin) {
        bottom = 3;
      }

      return BorderRadius.only(
        topLeft: Radius.circular(top),
        topRight: Radius.circular(top),
        bottomLeft: Radius.circular(bottom),
        bottomRight: Radius.circular(bottom),
      );
    }

    EdgeInsets getPadding(int index) {
      final first = index == 0;
      final last = index == widget.cards.length - 1;
      final origin = widget.cards[index].origin;
      final top = !first && widget.cards[index - 1].origin != origin ? 3.0 : 12.0;
      final bottom = !last && widget.cards[index + 1].origin != origin ? 3.0 : 12.0;

      return EdgeInsets.only(top: top, bottom: bottom);
    }

    return Scaffold(
      appBar: AppBar(title: Text('Test on ${widget.testArea}'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ...List<TestInput>.generate(
              widget.cards.length,
              (index) => TestInput(
                name: widget.cards[index].name,
                area: widget.cards[index].origin,
                onChanged: (str) => answers[index] = str,
                borderRadius: getRadius(index),
                padding: getPadding(index),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: FilledButton.tonal(onPressed: Navigator.of(context).pop, child: const Text('Cancel')),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
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
