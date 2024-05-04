import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/results_page.dart';
import 'package:flutter_application_1/states/test.dart';
import 'package:flutter_application_1/widgets/test_input.dart';

class TestPage extends StatefulWidget {
  final List<TestCard> cards;
  final String testArea;
  const TestPage({super.key, required this.cards, required this.testArea});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  Test test = Test({});
  List<String> answers = [];

  @override
  void initState() {
    test = Test({for (TestCard card in widget.cards) card: false});
    answers = [for (var _ in widget.cards) ''];
    super.initState();
  }

  void submitAnswers() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultsPage(test: test, answers: answers, cards: widget.cards),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test on ${widget.testArea}')),
      body: ListView(
        children: [
          ListView.builder(
            physics: const ScrollPhysics(),
            shrinkWrap: true,
            itemCount: widget.cards.length,
            itemBuilder: (context, index) => TestInput(
              name: widget.cards[index].name,
              onChanged: (str) => answers[index] = str,
            ),
          ),
          TextButton(onPressed: submitAnswers, child: const Text('Submit Answers')),
        ],
      ),
    );
  }
}