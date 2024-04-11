import "package:confirm_dialog/confirm_dialog.dart";
import "package:flutter/material.dart";
import "package:flutter_application_1/states/term.dart";
import "package:flutter_application_1/states/topic.dart";

// ignore: unused_import
import 'dart:developer' as developer;

import "package:flutter_application_1/utils.dart";
import "package:prompt_dialog/prompt_dialog.dart";

class StudyPage extends StatefulWidget {
  final List<Term> terms;
  final Topic topic;
  final Function(String) renameCallback;
  const StudyPage({super.key, required this.terms, required this.topic, required this.renameCallback});

  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
  int currentTerm = 0;
  bool showingMeaning = false;
  List<Term> terms = [];

  @override
  void initState() {
    terms = widget.terms.where((term) => !term.learned).toList() + widget.terms.where((term) => term.learned).toList();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String getCurrentText() {
    Term term = terms[currentTerm];
    if (showingMeaning) {
      return term.meaning;
    } else {
      return term.name;
    }
  }

  void goForward() {
    setState(() {
      currentTerm++;
      wrapCurrentTerm();
    });
  }

  void goBackward() {
    setState(() {
      currentTerm--;
      wrapCurrentTerm();
    });
  }

  void wrapCurrentTerm() {
    currentTerm = currentTerm % terms.length;
    showingMeaning = false;
  }

  void learnTerm() => setState(() {
        terms[currentTerm].learned = !terms[currentTerm].learned;
      });

  void editTerm() async {
    if (showingMeaning) {
      String newMeaning = await prompt(context,
              title: Text('New meaning for ${terms[currentTerm].name}'), initialValue: terms[currentTerm].meaning) ??
          '';
      if (newMeaning == '') return;
      setState(() {
        terms[currentTerm].meaning = newMeaning;
      });
    } else {
      String? newName = await prompt(context,
              title: Text('Rename ${terms[currentTerm].name}'), initialValue: terms[currentTerm].name) ??
          '';
      if (newName == '') return;
      setState(() {
        terms[currentTerm].name = newName;
      });
    }
  }

  void deleteTerm() async {
    bool delete = await confirm(context,
        title: Text('Are you sure you would like to delete ${terms[currentTerm].name}?'),
        content: const Text('This action cannot be undone. '));
    if (delete) {
      if (terms.length == 1) {
        widget.terms.removeAt(0);
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
        return;
      }
      setState(() => widget.terms.removeAt(currentTerm));
    }
  }

  void editTopicName() async {
    String newName =
        await prompt(context, title: Text('Rename ${widget.topic.name}'), initialValue: widget.topic.name) ?? '';
    if (newName == '') return;
    setState(() {
      widget.topic.name = newName;
      widget.renameCallback(newName);
    });
  }

  @override
  Widget build(BuildContext context) {
    //Create row including next and previous buttons
    Row buttons = Row(children: [
      AnimatedOpacity(
        duration: Durations.short1,
        opacity: currentTerm == 0 ? 0.2 : 1,
        child: GradientOutline(
          gradient: Theming.grayGradient,
          child: FloatingActionButton(
            heroTag: 'backwardbtn',
            onPressed: goBackward,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            hoverElevation: 0,
            child: const Icon(Icons.arrow_back_ios_rounded),
          ),
        ),
      ),
      const Spacer(),
      AnimatedOpacity(
        duration: Durations.short1,
        opacity: currentTerm == terms.length - 1 ? 0.2 : 1,
        child: GradientOutline(
          gradient: Theming.grayGradient,
          child: FloatingActionButton(
            onPressed: goForward,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            hoverElevation: 0,
            child: const Icon(Icons.arrow_forward_ios_rounded),
          ),
        ),
      )
    ]);

    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              Center(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(icon: const Icon(Icons.edit_rounded), onPressed: editTopicName),
                  SizedBox(
                    height: 75,
                    child: Text(
                      widget.topic.name,
                      style: const TextStyle(fontSize: 35, height: 2),
                    ),
                  ),
                ],
              )),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 0, 20, 0),
                  child: InkWell(
                    hoverColor: Colors.transparent,
                    onTap: () => setState(() => showingMeaning = !showingMeaning),
                    child: AnimatedContainer(
                      duration: Durations.long1,
                      decoration: BoxDecoration(boxShadow: [
                        BoxShadow(
                          color: !terms[currentTerm].learned
                              ? Theming.boxShadowColor
                              : const Color.fromARGB(80, 30, 253, 0),
                          spreadRadius: 0,
                          blurRadius: 20,
                        )
                      ]),
                      child: GradientOutline(
                          gradient: terms[currentTerm].learned
                              ? Theming.gradientToDarker(const Color.fromARGB(80, 30, 253, 0))
                              : Theming.coloredGradient,
                          child: Center(
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
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: editTerm,
                    icon: const Icon(Icons.mode_edit_rounded),
                  ),
                  SizedBox(
                    height: 75,
                    child: GradientOutline(
                      gradient: Theming.grayGradient,
                      child: FilledButton.tonal(
                        style: Theming.transparentButtonStyle,
                        onPressed: learnTerm,
                        child: Text(terms[currentTerm].learned ? 'Mark as unlearned' : 'Mark as learned',
                            style: const TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: deleteTerm,
                    icon: const Icon(Icons.delete_forever_rounded),
                  ),
                ],
              ),
            ],
          ),
          Center(child: buttons),
        ],
      ),
    );
  }
}
