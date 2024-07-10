import 'package:flutter/material.dart';
import 'package:studyappcs/states/subject.dart';

class SubjectCard extends StatefulWidget {
  const SubjectCard({super.key, required this.subject});
  final Subject subject;

  @override
  State<SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends State<SubjectCard> {
  bool selected = false;

  @override
  Widget build(BuildContext context) {
    final subject = widget.subject;
    String classroom;
    String teacher;
    final arr = <String>[subject.teacher, subject.classroom];
    [teacher, classroom] = arr;

    return Card(
      elevation: 5,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: <Widget>[
            SizedBox(
              height: 100,
              child: AspectRatio(
                aspectRatio: 1,
                child: Card(color: subject.color, elevation: 10),
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  children: <Widget>[
                    Hero(
                      tag: subject.name,
                      child: Material(
                        type: MaterialType.transparency,
                        child: Text(widget.subject.name, style: Theme.of(context).textTheme.headlineMedium),
                      ),
                    ),
                    if (!(teacher == '' && classroom == '')) ...<Widget>[
                      const SizedBox(height: 10),
                      Text(arr.where((String a) => a != '').join(' - '), style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
