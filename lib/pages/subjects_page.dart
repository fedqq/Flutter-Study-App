// ignore_for_file: use_build_context_synchronously

import 'dart:ffi';
import 'dart:ui';

import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/subject_page.dart';
import 'package:flutter_application_1/states/subject.dart';
import 'package:flutter_application_1/utils.dart';
import 'package:flutter_application_1/reused_widgets/expandable_fab.dart';
import 'package:flutter_application_1/reused_widgets/input_dialogs.dart';
import 'package:flutter_application_1/widgets/subject_card.dart';
import 'package:flutter_application_1/widgets/subject_option_menu.dart';

// ignore: unused_import
import 'dart:developer' as developer;

class SubjectsPage extends StatefulWidget {
  final List<Subject> subjects;
  const SubjectsPage({super.key, required this.subjects});

  @override
  State<SubjectsPage> createState() => _SubjectsPageState();
}

class _SubjectsPageState extends State<SubjectsPage> with TickerProviderStateMixin {
  int currentFocused = -1;

  late AnimationController enterController;
  late Animation<double> enterAnimation;
  late AnimationController blurController;
  late Animation<double> blurAnimation;

  @override
  void initState() {
    enterController = AnimationController(vsync: this, value: 0, duration: Durations.long1);

    enterAnimation = CurvedAnimation(
      curve: Curves.easeOut,
      parent: enterController,
    );

    blurController = AnimationController(vsync: this, value: 0, duration: Durations.short3);

    blurAnimation = CurvedAnimation(
      curve: Curves.easeInOutSine,
      reverseCurve: Curves.easeInOutSine,
      parent: blurController,
    );
    super.initState();
  }

  @override
  void dispose() {
    enterController.dispose();
    blurController.dispose();
    super.dispose();
  }

  void study(Subject subject) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => SubjectPage(subject: subject)))
          .then((value) => setState(() => currentFocused = -1));

  void newSubject() async {
    bool validate(String str) {
      if (getSubjectNames().contains(str)) {
        simpleSnackBar(context, 'Subject named $str already exists');
        return false;
      }
      return true;
    }

    String name = await showInputDialog(context, 'New Subject Name', 'Name', extraValidate: validate) ?? '';

    if (name == '') return;

    Color? newColor = await showColorPicker(context, Colors.blue);
    if (newColor == null) {
      return;
    }

    final subject = Subject(name, newColor);
    setState(() {
      widget.subjects.add(subject);
    });
  }

  void deleteSubject(int index) async {
    if (widget.subjects.length == 1) return;
    if (index == -1) index = currentFocused;
    if (await confirm(context, title: Text('Delete ${widget.subjects[index].name}'))) {
      setState(() => widget.subjects.removeAt(index));
    }
  }

  void editColor(int index) async {
    if (index == -1) index = currentFocused;
    Color? newColor = await showColorPicker(context, widget.subjects[index].color);
    if (newColor == null) return;
    setState(() => widget.subjects[index].color = newColor);
  }

  List<String> getSubjectNames() => List.generate(widget.subjects.length, (index) => widget.subjects[index].name);

  void editSubject(int index) async {
    if (index == -1) {
      index = currentFocused;
    }

    bool validate(String str) {
      if (getSubjectNames().contains(str)) {
        simpleSnackBar(context, 'Subject named $str already exists');
        return false;
      }
      return true;
    }

    String newName =
        await showInputDialog(context, 'Rename ${widget.subjects[index].name}', 'Name', extraValidate: validate) ?? '';

    if (newName == '') return;

    setState(() => widget.subjects[index].name = newName);
  }

  void clearSubjects() async {
    bool confirmed = await confirm(context,
        title: const Text('Delete All Subjects'),
        content: const Text('Are you sure you would like to delete all subjects? This action cannot be undone. '));
    if (confirmed) {
      widget.subjects.clear();
    }
  }

  void studyAll() {}

  @override
  Widget build(BuildContext context) {
    enterController.forward();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
          scrolledUnderElevation: 0,
          centerTitle: true,
          title: Text(widget.subjects.length == 1 ? 'Study 1 Subject' : 'Study ${widget.subjects.length} Subjects',
              style: const TextStyle(fontWeight: FontWeight.bold))),
      floatingActionButton: ExpandableFab(
        distance: 112,
        children: [
          ActionButton(
            onPressed: newSubject,
            icon: const Icon(Icons.add_rounded),
          ),
          ActionButton(
            onPressed: clearSubjects,
            icon: const Icon(Icons.delete_rounded),
          ),
          ActionButton(
            onPressed: studyAll,
            icon: const Icon(Icons.school_rounded),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () async {
          await blurController.reverse();
          setState(() {
            currentFocused = -1;
          });
        },
        child: AnimatedBuilder(
          animation: enterController,
          builder: (context, _) => ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8 + (60 * (1 - enterAnimation.value))),
            itemCount: widget.subjects.length,
            itemBuilder: (context, index) => GestureDetector(
              onTap: () async {
                if (currentFocused == -1 ? false : currentFocused != index) {
                  await blurController.reverse();
                  setState(() {
                    currentFocused = -1;
                  });
                } else {
                  study(widget.subjects[index]);
                }
              },
              onLongPress: () => setState(() {
                currentFocused = index;
                blurController.forward();
              }),
              child: AnimatedBuilder(
                animation: blurAnimation,
                builder: (_, __) => ImageFiltered(
                  imageFilter: (currentFocused == -1 ? false : currentFocused != index)
                      ? ImageFilter.blur(
                          sigmaX: 8 * blurAnimation.value, sigmaY: 8 * blurAnimation.value, tileMode: TileMode.decal)
                      : ImageFilter.blur(
                          sigmaX: 8 * (1 - enterAnimation.value), sigmaY: 8 * (1 - enterAnimation.value)),
                  child: Stack(children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: widget.subjects[index].color.withAlpha((60 * enterAnimation.value).toInt()),
                            blurRadius: 10.0 * enterAnimation.value,
                            spreadRadius: currentFocused == index ? 0 : -8,
                          ),
                        ],
                      ),
                      child: SubjectCard(subject: widget.subjects[index]),
                    ),
                    if (currentFocused == index)
                      SubjectOptionMenu(
                        editSubject: () => editSubject(-1),
                        editColor: () => editColor(-1),
                        deleteSubject: () => deleteSubject(-1),
                      )
                  ]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
