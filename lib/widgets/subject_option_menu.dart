import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils.dart';
import 'package:flutter_application_1/widgets/gradient_widgets.dart';

class SubjectOptionMenu extends StatelessWidget {
  final Function() editSubject;
  final Function() editColor;
  final Function() deleteSubject;
  const SubjectOptionMenu({super.key, required this.editSubject, required this.editColor, required this.deleteSubject});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      top: 120,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: OverflowBox(
          maxHeight: 75,
          child: SizedBox(
            height: 75,
            child: GradientOutline(
              gradient: Theming.grayGradient,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.color_lens_rounded),
                    onPressed: () => editColor(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_rounded),
                    onPressed: () => editSubject(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_rounded),
                    onPressed: () => deleteSubject(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
