import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:studyappcs/data_managers/firestore_manager.dart' as firestore_manager;
import 'package:studyappcs/widgets/subject_card.dart';

class SubjectOptionMenu extends StatelessWidget {
  final Function() editSubject;
  final Function() editColor;
  final Function() deleteSubject;
  final Function() testSubject;
  final Function() editInfo;
  final int index;
  final Animation<double> animation;

  const SubjectOptionMenu({
    super.key,
    required this.editSubject,
    required this.editColor,
    required this.deleteSubject,
    required this.animation,
    required this.testSubject,
    required this.index,
    required this.editInfo,
  });

  Widget pIconButton({icon, onPressed, label = 'test'}) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton.filledTonal(
              padding: const EdgeInsets.all(8),
              icon: icon,
              onPressed: onPressed,
            ),
          ),
          Text(label),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Align(
      child: AnimatedBuilder(
        animation: animation,
        builder: (_, __) => ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: (1 - animation.value) * 5, sigmaY: (1 - animation.value) * 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              SubjectCard(subject: firestore_manager.subjectsList[index], width: 3),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    pIconButton(icon: const Icon(Icons.color_lens_rounded), onPressed: editColor, label: 'Color'),
                    pIconButton(icon: const Icon(Icons.edit_rounded), onPressed: editSubject, label: 'Rename'),
                    pIconButton(icon: const Icon(Icons.question_mark_rounded), onPressed: testSubject, label: 'Test'),
                    pIconButton(icon: const Icon(Icons.edit_location_alt_rounded), onPressed: editInfo, label: 'Info'),
                    pIconButton(icon: const Icon(Icons.edit_location_alt_rounded), onPressed: editInfo, label: 'Study'),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton.filled(
                  onPressed: () {
                    deleteSubject();
                  },
                  icon: const Icon(Icons.delete_rounded),
                ),
              ),
              const Text('Delete Subject'),
            ],
          ),
        ),
      ),
    );
  }
}
