import 'package:flutter/material.dart';
import 'package:studyappcs/state_managers/firestore_manager.dart';
import 'package:studyappcs/states/test.dart';
import 'package:studyappcs/widgets/result_card.dart';

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
    cards = widget.test.scored.keys.toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    BorderRadius getRadius(int index) {
      Radius top = Radius.circular(index == 0 ? 12 : 3);
      Radius bottom = Radius.circular(index == cards.length - 1 ? 12 : 3);

      return BorderRadius.only(topLeft: top, topRight: top, bottomLeft: bottom, bottomRight: bottom);
    }

    return Scaffold(
      appBar: AppBar(title: Text('Test on ${widget.test.area} - ${widget.test.date}'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
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
              correct: widget.test.scored[cards[index]],
              card: cards[index],
              answer: widget.test.answers[index],
              editable: widget.editable,
              markCorrect: () async {
                var testDocs = await FirestoreManager.testDocs;

                var cardsDocs = await testDocs.docs
                    .firstWhere((a) => a['id'] == widget.test.id)
                    .reference
                    .collection('testcards')
                    .get();

                cardsDocs.docs
                    .firstWhere((a) => a['name'] == cards[index].name && a['meaning'] == cards[index])
                    .reference
                    .set({'answer': cards[index].meaning}, merge);

                setState(() => widget.test.scored[cards[index]] = true);
              },
              borderRadius: getRadius(index),
            ),
          ),
        ],
      ),
    );
  }
}
