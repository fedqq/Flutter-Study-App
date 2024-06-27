import 'package:flutter/material.dart';
import 'package:studyappcs/states/subject.dart';

class SubjectsStatsPage extends StatefulWidget {
  final Subject subject;
  const SubjectsStatsPage({super.key, required this.subject});

  @override
  State<SubjectsStatsPage> createState() => _SubjectsStatsPageState();
}

class _SubjectsStatsPageState extends State<SubjectsStatsPage> {
  @override
  Widget build(BuildContext context) {
    final Subject subject = widget.subject;
    return Scaffold(
      appBar: AppBar(title: Text(subject.name)),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Card(
              margin: const EdgeInsets.all(8.0),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: CircularProgressIndicator(
                  strokeWidth: 10,
                  strokeCap: StrokeCap.round,
                  value: widget.subject.learned / widget.subject.total,
                ),
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.all(8.0),
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: CircularProgressIndicator(
                strokeWidth: 10,
                strokeCap: StrokeCap.round,
                value: widget.subject.learned / widget.subject.total,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
