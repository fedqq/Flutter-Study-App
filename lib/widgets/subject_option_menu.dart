import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/gradient_widgets.dart';

import '../utils/theming.dart';

class SubjectOptionMenu extends StatelessWidget {
  final Function() editSubject;
  final Function() editColor;
  final Function() deleteSubject;
  final Function() testSubject;

  final Function() exportSubject;
  final Animation animation;

  const SubjectOptionMenu({
    super.key,
    required this.editSubject,
    required this.editColor,
    required this.deleteSubject,
    required this.exportSubject,
    required this.animation,
    required this.testSubject,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      top: 120,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: AnimatedBuilder(
          animation: animation,
          builder: (_, __) => OverflowBox(
            maxHeight: 150,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: (1 - animation.value) * 5, sigmaY: (1 - animation.value) * 5),
              child: SizedBox(
                height: 75,
                child: GradientOutline(
                  innerPadding: 0,
                  gradient: Theming.grayGradient,
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
