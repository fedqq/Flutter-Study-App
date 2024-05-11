import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/outlined_card.dart';

class SubjectOptionMenu extends StatelessWidget {
  final Function() editSubject;
  final Function() editColor;
  final Function() deleteSubject;
  final Function() testSubject;
  final Function() exportSubject;
  final int index;
  final Animation animation;

  const SubjectOptionMenu({
    super.key,
    required this.editSubject,
    required this.editColor,
    required this.deleteSubject,
    required this.exportSubject,
    required this.animation,
    required this.testSubject,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: AnimatedBuilder(
        animation: animation,
        builder: (_, __) => ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: (1 - animation.value) * 5, sigmaY: (1 - animation.value) * 5),
          child: Column(
            children: [
              SizedBox(height: (116 * (index + 1)).toDouble() - 10),
              OutlinedCard(
                elevation: 2,
                color: Colors.transparent,
                radius: 20,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.color_lens_rounded),
                      onPressed: editColor,
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_rounded),
                      onPressed: editSubject,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_rounded),
                      onPressed: deleteSubject,
                    ),
                    IconButton(
                      icon: const Icon(Icons.share_rounded),
                      onPressed: exportSubject,
                    ),
                    IconButton(
                      icon: const Icon(Icons.question_mark_rounded),
                      onPressed: testSubject,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
