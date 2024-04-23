import "package:flutter/material.dart";
import "package:flutter_application_1/states/topic.dart";
import "package:flutter_application_1/states/subject.dart";
import "package:flutter_application_1/reused_widgets/input_dialogs.dart";
import "package:flutter_application_1/widgets/topic_card.dart";
import "package:multi_dropdown/multiselect_dropdown.dart";

// ignore: unused_import
import 'dart:developer' as developer;

import "../reused_widgets/gradient_widgets.dart";

class SubjectPage extends StatefulWidget {
  final Subject subject;
  const SubjectPage({super.key, required this.subject});

  @override
  State<SubjectPage> createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage> {
  late TextEditingController newTopicNameController;

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
    Expanded topicList = Expanded(
      child: ListView.builder(
        itemCount: widget.subject.topics.length,
        itemBuilder: (context, index) => TopicCard(topic: widget.subject.topics[index]),
      ),
    );

    Color bgColor = Theme.of(context).scaffoldBackgroundColor;
    Color gradientColor = Color.alphaBlend(bgColor.withAlpha(220), widget.subject.color);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text(widget.subject.name)),
      floatingActionButton: GradientActionButton(
        onPressed: () async {
          final String topicName = await showInputDialog(context, 'New Topic Name', 'Name') ?? '';

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
                Text('${widget.subject.name} Topics (${widget.subject.topics.length})',
                    style: Theme.of(context).textTheme.titleLarge),
                if (widget.subject.topics.isNotEmpty) topicList,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
