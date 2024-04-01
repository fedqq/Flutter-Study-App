import "package:flutter/material.dart";
import "package:flutter_application_1/term.dart";

import 'dart:developer' as developer;

import "package:flutter_application_1/utils.dart";

class StudyPage extends StatefulWidget {
  final List<Term> terms;
  final String name;
  const StudyPage({super.key, required this.terms, required this.name});

  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
  int currentTerm = 0;
  bool showingMeaning = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String getCurrentText() {
    Term term = widget.terms[currentTerm];
    if (showingMeaning) {
      return term.meaning;
    } else {
      return term.name;
    }
  }

  void goForward() {
    currentTerm++;
    wrapCurrentTerm();
  }

  void goBackward() {
    currentTerm--;
    wrapCurrentTerm();
  }

  void wrapCurrentTerm() => setState(() {
        currentTerm = currentTerm % widget.terms.length;
        developer.log('Current: $currentTerm. Length: ${widget.terms.length}');
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            AnimatedOpacity(
              duration: Durations.short1,
              opacity: currentTerm == 0 ? 0.2 : 1,
              child: Theming.grayOutline(FloatingActionButton(
                heroTag: 'first',
                onPressed: goBackward,
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                hoverElevation: 0,
                child: const Icon(Icons.arrow_back_ios_rounded),
              )),
            ),
            Expanded(
              child: Theming.gradientOutline(Center(
                child: Text(getCurrentText()),
              )),
            ),
            AnimatedOpacity(
              duration: Durations.short1,
              opacity: currentTerm == widget.terms.length - 1 ? 0.2 : 1,
              child: Theming.grayOutline(FloatingActionButton(
                onPressed: goForward,
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                hoverElevation: 0,
                child: const Icon(Icons.arrow_forward_ios_rounded),
              )),
            )
          ],
        ),
      ),
    );
  }
}
