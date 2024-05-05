import 'package:flutter/material.dart';
import 'package:flutter_application_1/states/test.dart';
import 'package:flutter_application_1/widgets/result_card.dart';

class ResultsPage extends StatefulWidget {
  final Test test;
  final bool editable;
  const ResultsPage({super.key, required this.test, this.editable = true});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  late List<TestCard> cards;

  @override
  void initState() {
    cards = widget.test.cardCorrect.keys.toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test on ${widget.test.area} - ${widget.test.date}')),
      body: ListView(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'You got ${widget.test.percentage}% correct\n(${widget.test.correct} / ${widget.test.totalAmount})',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          ListView.builder(
            physics: const ScrollPhysics(),
            shrinkWrap: true,
            itemCount: cards.length,
            itemBuilder: (context, index) => ResultCard(
              correct: widget.test.cardCorrect[cards[index]],
              card: cards[index],
              answer: widget.test.answers[index],
              editable: widget.editable,
              markCorrect: () => setState(() => widget.test.cardCorrect[cards[index]] = true),
            ),
          ),
        ],
      ),
    );
  }
}
