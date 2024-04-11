import "package:flutter/material.dart";
import "package:flutter_application_1/states/topic.dart";
import "package:flutter_application_1/states/subject.dart";
import "package:flutter_application_1/widgets/topic_view.dart";
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

  @override
  Widget build(BuildContext context) {
    const int radius = 20;

    Expanded topicList = Expanded(
      child: ListView.builder(
        itemCount: widget.subject.topics.length,
        itemBuilder: (context, index) => TopicView(topic: widget.subject.topics[index]),
      ),
    );

    Color bgColor = Theme.of(context).scaffoldBackgroundColor;
    Color gradientColor = Color.alphaBlend(bgColor.withAlpha(220), widget.subject.color);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text(widget.subject.name)),
      floatingActionButton: GradientFAB(
        onPressed: () async {
          final topicName = await prompt(
                context,
                title: const Text('New Topic Name'),
              ) ??
              '';
          Topic topic = Topic(topicName);
          if (topic.name == '') return;

          setState(() {
            widget.subject.addTopic(topic);
          });
        },
        tooltip: 'New Topic',
        child: const Icon(Icons.add_rounded),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [bgColor, gradientColor],
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              children: [
                const Align(alignment: Alignment.centerLeft),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Hero(
                      tag: 'colorbox:${widget.subject.name}',
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(radius - 10)),
                            gradient: Theming.gradientToDarker(widget.subject.color)),
                      )),
                ),
                if (widget.subject.topics.isNotEmpty) topicList,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
