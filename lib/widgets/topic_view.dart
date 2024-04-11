// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/study_page.dart';
import 'package:flutter_application_1/states/term.dart';
import 'package:flutter_application_1/states/topic.dart';
import 'package:flutter_application_1/utils.dart';
import 'package:prompt_dialog/prompt_dialog.dart';

class TopicView extends StatefulWidget {
  final Topic topic;
  const TopicView({super.key, required this.topic});

  @override
  State<TopicView> createState() => _TopicViewState();
}

class _TopicViewState extends State<TopicView> {
  void renameCallback(String newName) {
    setState(() {
      widget.topic.name = newName;
    });
  }

  void studyTopic(Topic topic) => Navigator.push(
      context,
      PageRouteBuilder(
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            Animatable<Offset> tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          pageBuilder: (_, __, ___) => StudyPage(
                terms: topic.terms,
                topic: topic,
                renameCallback: renameCallback,
              ))).then((_) => setState(() {}));

  void renameTopic(Topic topic) async {
    String newName = await prompt(
          context,
          title: Text('Rename ${topic.name}'),
        ) ??
        '';
    if (newName == '') return;
    setState(() => topic.name = newName);
  }

  void addTerm(Topic topic) async {
    String name = await prompt(context, title: const Text('New Term Name')) ?? '';
    if (name == '') return;
    String meaning = await prompt(context, title: const Text('New Term Meaning')) ?? '';
    if (meaning == '') return;
    setState(() => topic.terms.add(Term(name, meaning, false)));
  }

  @override
  Widget build(BuildContext context) {
    Topic topic = widget.topic;
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Theming.boxShadowColor,
            blurRadius: 10,
            spreadRadius: -10,
          ),
        ],
      ),
      child: GradientOutline(
        child: ListTileTheme(
          contentPadding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
          minLeadingWidth: 10,
          child: ExpansionTile(
            controlAffinity: ListTileControlAffinity.leading,
            shape: const Border(),
            onExpansionChanged: (expanded) => setState(() {
              final controller = ExpansionTileController.maybeOf(context);
              if (expanded) {
                controller?.collapse();
              } else {
                controller?.expand();
              }
            }),
            trailing: SizedBox(
              width: 120,
              height: 40,
              child: Row(
                children: [
                  IconButton(
                      onPressed: () => topic.terms.isNotEmpty ? studyTopic(topic) : null,
                      icon: const Icon(Icons.school_rounded)),
                  IconButton(
                    onPressed: () => renameTopic(topic),
                    icon: const Icon(Icons.edit_rounded),
                  ),
                  IconButton(
                    onPressed: () => addTerm(topic),
                    icon: const Icon(Icons.add_rounded),
                  ),
                ],
              ),
            ),
            title: Text(
              topic.name,
              textAlign: TextAlign.center,
            ),
            childrenPadding: const EdgeInsets.all(0),
            children: List.generate(
                topic.terms.length,
                (termIndex) => ListTile(
                      minVerticalPadding: 0,
                      contentPadding: const EdgeInsets.all(8.0),
                      title: Text(topic.terms[termIndex].name),
                    )),
          ),
        ),
      ),
    );
  }
}
