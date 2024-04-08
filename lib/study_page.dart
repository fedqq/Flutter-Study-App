import "package:flutter/material.dart";
import "package:flutter_application_1/term.dart";

// ignore: unused_import
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
  OverlayEntry? entry;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    entry?.remove();
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

  void wrapCurrentTerm() {
    void wrap() {
      currentTerm = currentTerm % widget.terms.length;
      showingMeaning = false;
    }

    setState(wrap);
    Overlay.of(context).setState(wrap);
  }

  void learnTerm() => setState(() => widget.terms[currentTerm].learned = true);

  @override
  Widget build(BuildContext context) {
    //Remove the next and previous buttons currently overlayed
    entry?.remove();

    //Create row including next and previous buttons
    Row buttons = Row(children: [
      AnimatedOpacity(
        duration: Durations.short1,
        opacity: currentTerm == 0 ? 0.2 : 1,
        child: Theming.grayOutline(FloatingActionButton(
          onPressed: goBackward,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          hoverElevation: 0,
          child: const Icon(Icons.arrow_back_ios_rounded),
        )),
      ),
      const Spacer(),
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
    ]);

    entry = OverlayEntry(builder: (context) => buttons);

    //Overlay the buttons on top of the current overlay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Overlay.of(context).insert(entry!);
    });

    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: InkWell(
                onTap: () => setState(() => showingMeaning = !showingMeaning),
                child: Theming.gradientOutline(Center(
                  child: Padding(
                    padding: const EdgeInsets.all(45.0),
                    child: Text(
                      getCurrentText(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 25),
                    ),
                  ),
                )),
              ),
            ),
          ),
          Theming.grayOutline(
            FilledButton.tonal(
              style: Theming.transparentButtonStyle,
              onPressed: learnTerm,
              child: Text(widget.terms[currentTerm].learned ? 'Mark as unlearned' : 'Mark as learned',
                  style: const TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
