import "package:flutter/material.dart";
import "package:flutter_application_1/data_manager.dart";
import "package:flutter_application_1/topic.dart";
import "package:flutter_application_1/subject.dart";
import "package:flutter_application_1/utils.dart";
import "package:multi_dropdown/multiselect_dropdown.dart";

import 'package:prompt_dialog/prompt_dialog.dart';
import 'dart:developer' as developer;

class StudyPage extends StatefulWidget {
  final Subject subject;
  const StudyPage({super.key, required this.subject});

  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
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

  LinearGradient darkerGradient(Color color) {
    HSLColor hsl = HSLColor.fromColor(color);
    hsl = hsl.withLightness(hsl.lightness - 0.2);
    return LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [color, hsl.toColor()]);
  }

  void selectTopic(List<ValueItem<dynamic>> topics) {}

  List<ValueItem> buildValueItems() {
    developer.log(widget.subject.topics.toString());
    List<ValueItem> names = [];
    int i = 1;
    for (Topic t in widget.subject.topics) {
      names.add(ValueItem(label: t.name, value: i.toString()));
      i++;
    }
    developer.log(names.toString());
    return names;
  }

  @override
  Widget build(BuildContext context) {
    developer.log(widget.subject.topics.toString());
    const int radius = 20;
    dropdownOptions = buildValueItems();

    Key dropdownKey = UniqueKey();

    return Scaffold(
        appBar: AppBar(title: Text(widget.subject.name)),
        floatingActionButton: Theming.gradientOutline(
          FloatingActionButton(
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
                widget.subject.addTopic(topic);
                dropdownOptions = buildValueItems();
                DataManager.addTopic(widget.subject, topic);
              });
            },
            tooltip: 'New Topic',
            backgroundColor: Theme.of(context).splashColor,
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
                          gradient: darkerGradient(widget.subject.color)),
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
              )
            ],
          ),
        ));
  }
}
