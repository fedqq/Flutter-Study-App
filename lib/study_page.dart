import "package:flutter/material.dart";
import "package:flutter_application_1/data_manager.dart";
import "package:flutter_application_1/topic.dart";
import "package:flutter_application_1/subject.dart";
import 'dart:developer' as developer;

class StudyPage extends StatefulWidget {
  final Subject subject;
  const StudyPage({super.key, required this.subject});

  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
  late TextEditingController newTopicNameController;

  @override
  void initState() {
    developer.log(widget.subject.topics.toString());
    newTopicNameController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    newTopicNameController.dispose();
    super.dispose();
  }

  LinearGradient grad(Color color) {
    HSLColor hsl = HSLColor.fromColor(color);
    hsl = hsl.withLightness(hsl.lightness - 0.2);
    return LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [color, hsl.toColor()]);
  }

  @override
  Widget build(BuildContext context) {
    const int radius = 20;

    return Scaffold(
        appBar: AppBar(title: Text(widget.subject.name)),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final topic = await newSubjectDialog();
            if (topic == null || topic.name == '') {
              return;
            }
            setState(() {
              widget.subject.addTopic(topic);
            });
            DataManager.addTopic(widget.subject, topic);
          },
          tooltip: 'New Topic',
          backgroundColor: Theme.of(context).indicatorColor,
          child: const Icon(Icons.add),
        ),
        body: Center(
          child: Column(
            children: [
              Align(
                  alignment: Alignment.centerLeft,
                  child: Hero(tag: 'icon:${widget.subject.name}', child: Icon(widget.subject.icon, size: 50))),
              Hero(
                  tag: 'colorbox:${widget.subject.name}',
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(radius - 10)),
                        gradient: grad(widget.subject.color)),
                  )),
            ],
          ),
        ));
  }

  void submitNewSubject(context) {
    Navigator.of(context).pop(Topic(newTopicNameController.text));
    newTopicNameController.clear();
  }

  Future<Topic?> newSubjectDialog() => showDialog<Topic?>(
      context: context,
      builder: (context) => AlertDialog(
          title: const Text('New Topic Name'),
          content: TextField(
            controller: newTopicNameController,
            autofocus: true,
            onSubmitted: (String? _) => submitNewSubject(context),
          ),
          actions: [TextButton(onPressed: () => submitNewSubject(context), child: const Text('Confirm'))]));
}
