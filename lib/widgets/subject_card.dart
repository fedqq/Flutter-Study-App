import 'package:flutter/material.dart';
import 'package:flutter_application_1/states/subject.dart';

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

    return Card(
      shadowColor: Colors.transparent,
      surfaceTintColor: subject.color,
      elevation: 15,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
      margin: const EdgeInsets.all(8.0),
      child: SizedBox.fromSize(
        size: const Size.fromHeight(100),
        child: Stack(
          children: [
            Center(
              child: Text(
                subject.name,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
