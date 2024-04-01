import "package:flutter/material.dart";
import "package:flutter_application_1/study_page.dart";
import "package:flutter_application_1/term.dart";
import "package:flutter_application_1/topic.dart";
import "package:flutter_application_1/subject.dart";
import "package:flutter_application_1/utils.dart";
import "package:multi_dropdown/multiselect_dropdown.dart";

import 'package:prompt_dialog/prompt_dialog.dart';
// ignore: unused_import
import 'dart:developer' as developer;

class SubjectPage extends StatefulWidget {
  final Subject subject;
  const SubjectPage({super.key, required this.subject});

  @override
  State<SubjectPage> createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage> {
  late TextEditingController newTopicNameController;
  List<ValueItem> dropdownOptions = [];

  @override
  void initState() {
    newTopicNameController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    newTopicNameController.dispose();
    super.dispose();
  }

  void selectTopic(List<ValueItem<dynamic>> topics) {}

  List<ValueItem> buildValueItems() {
    List<ValueItem> names = [];
    int i = 1;
    for (Topic t in widget.subject.topics) {
      names.add(ValueItem(label: t.name, value: i.toString()));
      i++;
    }
    return names;
  }

  @override
  Widget build(BuildContext context) {
    const int radius = 20;
    dropdownOptions = buildValueItems();

    Key dropdownKey = UniqueKey();

    return Scaffold(
        appBar: AppBar(title: Text(widget.subject.name)),
        floatingActionButton: Container(
          decoration: Theming.gradientDeco,
          child: FloatingActionButton(
            onPressed: () async {
              final topicName = await prompt(
                    context,
                    title: const Text('New Subject Name'),
                  ) ??
                  '';
              Topic topic = Topic(topicName);
              if (topic.name == '') {
                return;
              }
              setState(() {
                topic.addTerm(Term(
                    'First Term name',
                    'This is the meaning of the first term and it has to be long so that I can test the width and overflow settings. ',
                    false));
                topic.addTerm(Term('Term 2', 'Meaning 2', true));
                widget.subject.addTopic(topic);
                dropdownOptions = buildValueItems();
              });
            },
            tooltip: 'New Topic',
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            hoverElevation: 0,
            child: const Icon(Icons.add),
          ),
        ),
        body: Center(
          child: Column(
            children: [
              Align(
                  alignment: Alignment.centerLeft,
                  child: Hero(tag: 'icon:${widget.subject.name}', child: Icon(widget.subject.icon, size: 50))),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Hero(
                    tag: 'colorbox:${widget.subject.name}',
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(radius - 10)),
                          gradient: Theming.makeDarker(widget.subject.color)),
                    )),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: MultiSelectDropDown<dynamic>(
                  key: dropdownKey,
                  onOptionSelected: selectTopic,
                  options: dropdownOptions,
                  selectionType: SelectionType.multi,
                  chipConfig: const ChipConfig(wrapType: WrapType.wrap),
                  optionTextStyle: const TextStyle(fontSize: 16),
                  selectedOptionIcon: const Icon(Icons.check_circle),
                  fieldBackgroundColor: Theme.of(context).hoverColor,
                  optionsBackgroundColor: Theme.of(context).dialogBackgroundColor,
                  selectedOptionTextColor: Colors.white,
                  borderColor: Colors.white,
                  dropdownBackgroundColor: Theme.of(context).dialogBackgroundColor,
                  selectedOptionBackgroundColor: Theme.of(context).primaryColorDark,
                  dropdownHeight: dropdownOptions.length * 40,
                  dropdownBorderRadius: 20,
                  radiusGeometry: const BorderRadius.all(Radius.circular(20)),
                ),
              ),
              if (widget.subject.topics.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                      itemCount: widget.subject.topics.length,
                      itemBuilder: (context, index) => InkWell(
                            onTap: () => Navigator.push(
                                context,
                                PageRouteBuilder(
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      const begin = Offset(0.0, 1.0);
                                      const end = Offset.zero;
                                      const curve = Curves.ease;

                                      Animatable<Offset> tween =
                                          Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                                      return SlideTransition(
                                        position: animation.drive(tween),
                                        child: child,
                                      );
                                    },
                                    pageBuilder: (_, __, ___) => StudyPage(
                                        terms: widget.subject.topics[index].terms,
                                        name: widget.subject.topics[index].name))),
                            child: Theming.gradientOutline(
                              ListTile(
                                title: Text(
                                  widget.subject.topics[index].name,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          )),
                ),
            ],
          ),
        ));
  }
}
