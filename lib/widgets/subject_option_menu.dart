import 'package:flutter/material.dart';
import 'package:studyappcs/data_managers/firestore_manager.dart' as firestore_manager;
import 'package:studyappcs/widgets/subject_card.dart';

class SubjectOptionMenu extends StatelessWidget {
  const SubjectOptionMenu({
    super.key,
    required this.editSubject,
    required this.editColor,
    required this.deleteSubject,
    required this.testSubject,
    required this.editInfo,
    required this.animation,
    required this.index,
  });
  final Function() editSubject;
  final Function() editColor;
  final Function() deleteSubject;
  final Function() testSubject;
  final Function() editInfo;
  final int index;
  final Animation<double> animation;

  Widget pIconButton({required Icon icon, required void Function() onPressed, String label = 'test'}) => Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8),
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
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: animation,
      builder: (_, __) => Opacity(
        opacity: animation.value,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Spacer(),
            SubjectCard(subject: firestore_manager.subjectsList[index], width: 3),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  pIconButton(icon: const Icon(Icons.color_lens_rounded), onPressed: editColor, label: 'Color'),
                  pIconButton(icon: const Icon(Icons.edit_rounded), onPressed: editSubject, label: 'Rename'),
                  pIconButton(icon: const Icon(Icons.question_mark_rounded), onPressed: testSubject, label: 'Test'),
                  pIconButton(icon: const Icon(Icons.edit_location_alt_rounded), onPressed: editInfo, label: 'Info'),
                  pIconButton(icon: const Icon(Icons.school_rounded), onPressed: editInfo, label: 'Study'),
                ].map((Widget a) => ScaleTransition(scale: animation, child: a)).toList(),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(8),
              child: IconButton.filled(
                onPressed: deleteSubject,
                icon: const Icon(Icons.delete_rounded),
              ),
            ),
            const Text('Delete Subject'),
          ],
        ),
      ),
    );
}
