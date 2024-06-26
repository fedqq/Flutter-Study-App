import 'package:flutter/material.dart';
import 'package:studyappcs/states/subject.dart';

class SubjectCard extends StatefulWidget {
  final Subject subject;
  final double width;
  const SubjectCard({super.key, required this.subject, required this.width});

  @override
  State<SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends State<SubjectCard> {
  bool selected = false;

  @override
  Widget build(BuildContext context) {
    Subject subject = widget.subject;
    String classroom, teacher;
    List<String> arr = [subject.teacher, subject.classroom];
    [teacher, classroom] = arr;

    return Card(
      elevation: 5,
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
        child: Row(
          children: [
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
                  children: [
                    Hero(
                      tag: subject.name,
                      child: Text(subject.name, style: Theme.of(context).textTheme.headlineMedium),
                    ),
                    if (!(teacher == '' && classroom == '')) ...[
                      const SizedBox(height: 10),
                      Text(arr.where((a) => a != '').join(' - '), style: Theme.of(context).textTheme.bodyLarge),
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
