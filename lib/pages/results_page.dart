import 'package:flutter/material.dart';
import 'package:studyappcs/data_managers/firestore_manager.dart' as firestore_manager;
import 'package:studyappcs/states/test.dart';
import 'package:studyappcs/widgets/result_card.dart';

class ResultsPage extends StatefulWidget {
  const ResultsPage({super.key, required this.test, this.editable = true});
  final Test test;
  final bool editable;

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

  Future<void> overrideAsCorrect(int index) async {
    final testDocs = await firestore_manager.testDocs;

    final cardsDocs =
        await testDocs.docs.firstWhere((a) => a['id'] == widget.test.id).reference.collection('testcards').get();

    final docs = cardsDocs.docs;
    final ref = docs.firstWhere((a) => cards[index].compare(a)).reference;

    await ref.update(<Object, Object?>{'answer': cards[index].meaning});

    setState(() => widget.test.scored[cards[index]] = true);
  }

  @override
  Widget build(BuildContext context) {
    BorderRadius calculateRadius(int index) {
      final top = Radius.circular(index == 0 ? 12 : 3);
      final bottom = Radius.circular(index == cards.length - 1 ? 12 : 3);

      return BorderRadius.only(topLeft: top, topRight: top, bottomLeft: bottom, bottomRight: bottom);
    }

    return Scaffold(
      appBar: AppBar(title: Text('Test on ${widget.test.area} - ${widget.test.date}'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
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
              markCorrect: () => overrideAsCorrect(index),
              borderRadius: calculateRadius(index),
            ),
          ),
        ],
      ),
    );
  }
}
