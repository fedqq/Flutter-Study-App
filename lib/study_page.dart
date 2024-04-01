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

  void learnTerm() => setState(() => widget.terms[currentTerm].learned = true);

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
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: InkWell(
                        onTap: () => setState(() => showingMeaning = !showingMeaning),
                        child: Theming.gradientOutline(Center(
                          child: AnimatedDefaultTextStyle(
                              curve: Curves.ease,
                              duration: Durations.short1,
                              style: showingMeaning ? const TextStyle(fontSize: 30) : const TextStyle(fontSize: 40),
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Text(
                                  getCurrentText(),
                                  textAlign: TextAlign.center,
                                ),
                              )),
                        )),
                      ),
                    ),
                  ),
                  Theming.grayOutline(
                    FilledButton.tonal(
                      style: Theming.transparentButtonStyle,
                      onPressed: learnTerm,
                      child: const Text('Mark As Learned', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
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
