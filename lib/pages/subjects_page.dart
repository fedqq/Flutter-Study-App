// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:ui';

import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/all_tests_page.dart';
import 'package:flutter_application_1/pages/subject_page.dart';
import 'package:flutter_application_1/pages/study_page.dart';
import 'package:flutter_application_1/pages/test_page.dart';
import 'package:flutter_application_1/state_managers/exporter.dart';
import 'package:flutter_application_1/state_managers/statistics.dart';
import 'package:flutter_application_1/state_managers/tests_manager.dart';
import 'package:flutter_application_1/states/flashcard.dart';
import 'package:flutter_application_1/states/subject.dart';
import 'package:flutter_application_1/states/test.dart';
import 'package:flutter_application_1/states/topic.dart';
import 'package:flutter_application_1/utils/snackbar.dart';
import 'package:flutter_application_1/utils/expandable_fab.dart';
import 'package:flutter_application_1/utils/input_dialogs.dart';
import 'package:flutter_application_1/widgets/export_sheet.dart';
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
  ExFabController controller = ExFabController();

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

  void study(Subject subject) {
    closeMenus();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SubjectPage(
          subject: subject,
        ),
      ),
    );
  }

  void closeMenus() async {
    await blurController.reverse(from: 1);
    setState(() {
      controller.close();
      currentFocused = -1;
    });
  }

  void newSubject() async {
    closeMenus();
    bool validate(String str) {
      if (getSubjectNames().contains(str)) {
        simpleSnackBar(context, 'Subject named $str already exists');

        return false;
      }

      return true;
    }

    String name =
        await singleInputDialog(context, 'New Subject Name', InputType(name: 'Name', validate: validate)) ?? '';

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

  void deleteSubject() async {
    if (!await confirm(context, title: Text('Delete ${widget.subjects[currentFocused].name}'))) return;

    String area = widget.subjects[currentFocused].asArea.trim();
    setState(() => widget.subjects.removeAt(currentFocused));
    TestsManager.pastTests.removeWhere((element) => element.area.trim() == area);

    closeMenus();
  }

  void editColor() async {
    Color? newColor = await showColorPicker(context, widget.subjects[currentFocused].color);
    if (newColor == null) return;
    setState(() => widget.subjects[currentFocused].color = newColor);

    closeMenus();
  }

  void testSubject() async {
    List<TestCard> cards = [];
    Subject subject = widget.subjects[currentFocused];
    for (Topic topic in subject.topics) {
      for (FlashCard card in topic.cards) {
        cards.add(TestCard(card.name, card.meaning, '${subject.name} - ${topic.name}'));
      }
    }
    if (cards.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TestPage(
          cards: cards,
          testArea: subject.name,
          subject: subject,
        ),
      ),
    );

    closeMenus();
  }

  void exportSubject() async {
    showPrintOrExport(context, widget.subjects[currentFocused]);
    closeMenus();

    return;
  }

  void importSubject() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      String res = await file.readAsString();
      Subject subject;
      try {
        subject = Subject.fromString(res);
      } catch (e) {
        simpleSnackBar(context, 'Invalid Format. ');

        return;
      }
      while (getSubjectNames().contains(subject.name)) {
        subject.name += ' 2';
      }
      setState(() {
        widget.subjects.add(subject);
      });
    }
    closeMenus();
  }

  List<String> getSubjectNames() => List.generate(widget.subjects.length, (index) => widget.subjects[index].name);

  void editSubject() async {
    bool validate(String str) {
      if (getSubjectNames().contains(str)) {
        simpleSnackBar(context, 'Subject named $str already exists');

        return false;
      }

      return true;
    }

    String newName = await singleInputDialog(
          context,
          'Rename ${widget.subjects[currentFocused].name}',
          InputType(
            name: 'Name',
            validate: validate,
          ),
        ) ??
        '';

    if (newName == '') return;

    for (Test test in TestsManager.pastTests) {
      test.area = test.area.replaceAll(widget.subjects[currentFocused].name, newName);
    }

    setState(() => widget.subjects[currentFocused].name = newName);
    closeMenus();
  }

  void clearSubjects() async {
    bool confirmed = await confirm(
      context,
      title: const Text('Delete All Subjects'),
      content: const Text('Are you sure you would like to delete all subjects? This action cannot be undone. '),
    );
    if (confirmed) {
      setState(() {
        widget.subjects.clear();
        currentFocused = -1;
      });
    }
    closeMenus();
  }

  void studyAll() {
    closeMenus();
    List<FlashCard> cards = [];
    for (Subject subject in widget.subjects) {
      for (Topic topic in subject.topics) {
        cards += topic.cards;
      }
    }
    if (cards.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => StudyPage(cards: cards, topic: Topic('All Subjects'), renameCallback: null)),
    );
  }

  void showAllTests() {
    closeMenus();
    Navigator.push(context, MaterialPageRoute(builder: (_) => const AllTestsPage()));
  }

  @override
  Widget build(BuildContext context) {
    enterController.forward();

    Exporter.subjectToPdf(widget.subjects[0], 10);

    Widget fab = ExpandableFab(
      controller: controller,
      onPress: () async {
        await blurController.reverse(from: 1);
        setState(() => currentFocused = -1);
      },
      children: [
        ActionButton(
          onPressed: newSubject,
          icon: const Icon(Icons.add_rounded),
          name: 'New Subject',
        ),
        ActionButton(
          onPressed: clearSubjects,
          icon: const Icon(Icons.delete_forever_rounded),
          name: 'Clear Subjects',
        ),
        ActionButton(
          onPressed: studyAll,
          icon: const Icon(Icons.school_rounded),
          name: 'Study All',
        ),
        ActionButton(
          onPressed: importSubject,
          icon: const Icon(Icons.file_upload_rounded),
          name: 'Import Subject',
        ),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.history_rounded),
          onPressed: TestsManager.hasScore('') ? showAllTests : null,
        ),
        title: Text(
          widget.subjects.length == 1 ? 'Study 1 Subject' : 'Study ${widget.subjects.length} Subjects',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: fab,
      body: GestureDetector(
        onTap: closeMenus,
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: enterController,
          builder: (context, _) => widget.subjects.isEmpty
              ? const Center(
                  child: Text(
                    'No Subjects.\nExpand the menu and press + to make a new subject. ',
                    textAlign: TextAlign.center,
                  ),
                )
              : Stack(
                  children: [
                    ListView.builder(
                      physics: const ScrollPhysics(),
                      shrinkWrap: true,
                      clipBehavior: Clip.none,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      itemCount: widget.subjects.length,
                      itemBuilder: (context, index) => InkWell(
                        onTap: () async {
                          closeMenus();
                          if (currentFocused == -1 ? false : currentFocused != index) {
                            await blurController.reverse(from: 1);
                            setState(() => currentFocused = -1);
                          } else {
                            study(widget.subjects[index]);
                          }
                        },
                        onLongPress: () => setState(() {
                          closeMenus();
                          currentFocused = index;
                          blurController.forward(from: 0);
                        }),
                        child: AnimatedBuilder(
                          animation: blurController,
                          builder: (_, __) => ImageFiltered(
                            imageFilter: (currentFocused == -1 ? false : currentFocused != index)
                                ? ImageFilter.blur(
                                    sigmaX: 8 * blurAnimation.value,
                                    sigmaY: 8 * blurAnimation.value,
                                    tileMode: TileMode.decal,
                                  )
                                : ImageFilter.blur(
                                    sigmaX: 8 * (1 - enterAnimation.value),
                                    sigmaY: 8 * (1 - enterAnimation.value),
                                  ),
                            child: Stack(
                              children: [
                                SubjectCard(subject: widget.subjects[index], width: enterAnimation.value * 3),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (currentFocused != -1)
                      SubjectOptionMenu(
                        editSubject: editSubject,
                        editColor: editColor,
                        deleteSubject: deleteSubject,
                        exportSubject: exportSubject,
                        testSubject: testSubject,
                        animation: blurAnimation,
                        index: currentFocused,
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
