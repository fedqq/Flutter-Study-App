import "package:flutter/material.dart";
import "package:flutter_application_1/states/topic.dart";
import "package:flutter_application_1/states/subject.dart";
import "package:flutter_application_1/utils/input_dialogs.dart";
import "package:flutter_application_1/widgets/topic_card.dart";

// ignore: unused_import
import 'dart:developer' as developer;

import "../utils/gradient_widgets.dart";

class SubjectPage extends StatefulWidget {
  final Subject subject;
  const SubjectPage({super.key, required this.subject});

  @override
  State<SubjectPage> createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage> {
  void newTopic() async {
    final String topicName = await singleInputDialog(context, 'New Topic Name', InputType(name: 'Name')) ?? '';

    if (topicName == '') return;
    Topic topic = Topic(topicName);

    setState(() => widget.subject.addTopic(topic));
  }

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
        onPressed: newTopic,
        tooltip: 'New Topic',
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
                    style: Theme.of(context).textTheme.titleLarge,),
                if (widget.subject.topics.isNotEmpty) topicList,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
