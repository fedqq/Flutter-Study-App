import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/states/subject.dart';
import 'package:flutter_application_1/utils.dart';
import 'package:flutter_application_1/reused_widgets/gradient_widgets.dart';

class SubjectCard extends StatefulWidget {
  final Subject subject;
  const SubjectCard({super.key, required this.subject});

  @override
  State<SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends State<SubjectCard> {
  bool selected = false;

  @override
  Widget build(BuildContext context) {
    Subject subject = widget.subject;
    return GradientOutline(
      innerPadding: 8.0,
      gradient: Theming.grayGradient,
      child: Card(
        child: SizedBox.fromSize(
          size: const Size.fromHeight(100),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8, tileMode: TileMode.decal),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Theming.radius - Theming.padding - 8),
                      gradient: Theming.gradientToDarker(subject.color),
                    ),
                  ),
                ),
              ),
              Center(
                child: Container(
                  decoration: const BoxDecoration(boxShadow: [BoxShadow(blurRadius: 100, spreadRadius: 20)]),
                  child: Text(
                    subject.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
