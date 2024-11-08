// ignore_for_file: use_build_context_synchronously, always_specify_types

// ignore: unused_import
import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:studyappcs/data_managers/firestore_manager.dart' as firestore_manager;
import 'package:studyappcs/pages/all_tests_page.dart';
import 'package:studyappcs/pages/study_page.dart';
import 'package:studyappcs/pages/subject_page.dart';
import 'package:studyappcs/pages/test_page.dart';
import 'package:studyappcs/states/flashcard.dart';
import 'package:studyappcs/states/subject.dart';
import 'package:studyappcs/states/test.dart';
import 'package:studyappcs/utils/expandable_fab.dart';
import 'package:studyappcs/utils/input_dialogs.dart';
import 'package:studyappcs/utils/utils.dart';
import 'package:studyappcs/widgets/subject_card.dart';
import 'package:studyappcs/widgets/subject_option_menu.dart';

class SubjectsPage extends StatefulWidget {
  const SubjectsPage({super.key, required this.subjects});
  final List<Subject> subjects;

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
    enterController = AnimationController(vsync: this, value: 0, duration: const Duration(seconds: 1));

    enterAnimation = CurvedAnimation(
      curve: Curves.easeOutCirc,
      parent: enterController,
    );

    blurController = AnimationController(vsync: this, value: 0, duration: const Duration(milliseconds: 300));

    blurAnimation = CurvedAnimation(
      curve: Curves.easeOutCirc,
      reverseCurve: Curves.fastLinearToSlowEaseIn,
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

  Future<void> closeMenus() async {
    await blurController.reverse(from: 1);
    setState(() {
      currentFocused = -1;
      controller.close();
    });
  }

  bool validateSubjectName(String str) {
    if (str.trim() == 'All') {
      return false;
    }

    if (getSubjectNames().contains(str)) {
      simpleSnackBar(context, 'Subject named $str already exists');

      return false;
    }

    return true;
  }

  Future<void> newSubject() async {
    await closeMenus();

    final name = await inputDialog(
      context,
      'New Subject Name',
      Input(name: 'Name', validate: validateSubjectName),
    );

    if (name == '') {
      return;
    }

    final newColor = await showColorPicker(context, Colors.blue);
    if (newColor == null) {
      return;
    }

    final res = await doubleInputDialog(
      context,
      'Choose teacher and classroom',
      Input(name: 'Teacher', nullable: true),
      Input(name: 'Classroom', nullable: true),
    );

    if (res == null) {
      return;
    }

    final subject = Subject(name, newColor, res.first, res.second);

    await firestore_manager.subjectCollection.doc().set({
      'name': subject.name,
      'scores': <int>[],
      'color': newColor.value,
      'teacher': subject.teacher,
      'classroom': subject.classroom,
    });

    setState(() => widget.subjects.add(subject));
  }

  Future<void> deleteSubject() async {
    if (!await confirmDialog(context, title: 'Delete ${widget.subjects[currentFocused].name}')) {
      return;
    }

    final area = widget.subjects[currentFocused].name.trim();
    setState(() => widget.subjects.removeAt(currentFocused));
    firestore_manager.pastTests.removeWhere((element) => element.area.contains(area));

    final subject = await firestore_manager.subjectNamed(area);
    await subject.reference.delete();

    final cards = await firestore_manager.cardsFromSubject(area);
    for (final a in cards) {
      await a.reference.delete();
    }

    final tests = await firestore_manager.testDocs;
    tests.docs.where((a) => (a['area'] as String).contains(area)).forEach((a) => a.reference.delete());

    await closeMenus();
  }

  Future<void> editColor() async {
    final newColor = await showColorPicker(context, widget.subjects[currentFocused].color);
    if (newColor == null) {
      return;
    }
    setState(() => widget.subjects[currentFocused].color = newColor);

    final name = widget.subjects[currentFocused].name;

    final subject = await firestore_manager.subjectNamed(name);
    await subject.reference.update({'color': newColor.value});

    await closeMenus();
  }

  Future<void> testSubject() async {
    final cards = <TestCard>[];
    final subject = widget.subjects[currentFocused];
    for (final topic in subject.topics) {
      for (final card in topic.cards) {
        cards.add(TestCard(card.name, card.meaning, '${subject.name} - ${topic.name}'));
      }
    }
    if (cards.isEmpty) {
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TestPage(
          cards: cards,
          testArea: subject.name,
          subject: subject,
        ),
      ),
    );

    await closeMenus();
  }

  Future<void> studyCards() async {
    final cards = <FlashCard>[];
    final subject = widget.subjects[currentFocused];
    if (subject.topics.isEmpty) {
      return;
    }
    for (final topic in subject.topics) {
      topic.cards.forEach(cards.add);
    }
    await closeMenus();
    await Navigator.push(context, MaterialPageRoute(builder: (context) => StudyPage(cards: cards)));
  }

  List<String> getSubjectNames() =>
      List<String>.generate(widget.subjects.length, (index) => widget.subjects[index].name);

  Future<void> editSubject() async {
    final oldName = widget.subjects[currentFocused].name;
    final newName = await inputDialog(
      context,
      'Rename ${widget.subjects[currentFocused].name}',
      Input(
        name: 'Name',
        validate: validateSubjectName,
      ),
    );

    if (newName == '') {
      return;
    }

    unawaited(closeMenus());

    setState(() => widget.subjects[currentFocused].name = newName);

    for (final test in firestore_manager.pastTests) {
      test.area = test.area.replaceAll(widget.subjects[currentFocused].name, newName);
    }

    final tests = await firestore_manager.testsFromSubject(oldName);
    for (final test in tests) {
      await test.reference.update({'area': (test.get('area') as String).replaceAll(oldName, newName)});
    }

    final subject = await firestore_manager.subjectNamed(oldName);
    await subject.reference.update({'name': newName});

    final docs = await firestore_manager.cardsFromSubject(oldName);
    for (final card in docs) {
      await card.reference.update({'subject': newName});
    }
  }

  Future<void> editClassroomInfo() async {
    final res = await doubleInputDialog(
      context,
      'Choose teacher and classroom',
      Input(name: 'Teacher', nullable: true),
      Input(name: 'Classroom', nullable: true),
    );

    if (res == null) {
      return;
    }

    setState(() {
      widget.subjects[currentFocused].teacher = res.first;
      widget.subjects[currentFocused].classroom = res.second;
    });

    final subject = await firestore_manager.subjectNamed(widget.subjects[currentFocused].name);
    await subject.reference.update({'teacher': res.first, 'classroom': res.second});
  }

  Future<void> clearSubjects() async {
    final confirmed = await confirmDialog(
      context,
      title: 'Delete all Subjects',
    );

    if (!confirmed) {
      return;
    }

    final cardsCollection = firestore_manager.cardCollection;
    final cards = await cardsCollection.get();
    for (final a in cards.docs) {
      await a.reference.delete();
    }

    final subjectCollection = firestore_manager.subjectCollection;
    final subjects = await subjectCollection.get();
    for (final a in subjects.docs) {
      await a.reference.delete();
    }

    setState(() {
      widget.subjects.clear();
      currentFocused = -1;
    });

    await closeMenus();
  }

  void studyAll() {
    closeMenus();

    var cards = <FlashCard>[];
    for (final subject in widget.subjects) {
      for (final topic in subject.topics) {
        cards += topic.cards;
      }
    }
    if (cards.isEmpty) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => StudyPage(cards: cards)),
    );
  }

  void testAll() {
    final cards = <TestCard>[];
    for (final subject in widget.subjects) {
      for (final topic in subject.topics) {
        for (final card in topic.cards) {
          cards.add(TestCard(card.name, card.name, '${subject.name} - ${topic.name}'));
        }
      }
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TestPage(cards: cards, testArea: 'All')),
    );
  }

  void showAllTests() {
    closeMenus();
    Navigator.push(context, MaterialPageRoute(builder: (_) => const AllTestsPage()));
  }

  ExpandableFab buildFloatingActionButton() => ExpandableFab(
        controller: controller,
        onPress: () async {
          await blurController.reverse(from: 1);
          setState(() => currentFocused = -1);
        },
        children: <ActionButton>[
          ActionButton(onPressed: newSubject, icon: const Icon(Icons.add_rounded), name: 'New Subject'),
          if (widget.subjects.isNotEmpty) ...<ActionButton>[
            ActionButton(onPressed: clearSubjects, icon: const Icon(Icons.delete_rounded), name: 'Clear Subjects'),
            ActionButton(onPressed: studyAll, icon: const Icon(Icons.school_rounded), name: 'Study All'),
            ActionButton(onPressed: testAll, icon: const Icon(Icons.question_mark_rounded), name: 'Test All'),
          ],
        ],
      );

  AppBar buildAppBar() => AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.history_rounded),
          onPressed: firestore_manager.pastTests.isNotEmpty ? showAllTests : null,
        ),
        title: Text(
          widget.subjects.length == 1 ? 'Study 1 Subject' : 'Study ${widget.subjects.length} Subjects',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );

  Widget buildPlaceholderText() => const Center(
        child: Text(
          'No Subjects.\nExpand the menu and\npress + to make a new subject. ',
          textAlign: TextAlign.center,
        ),
      );

  SubjectOptionMenu buildOptions() => SubjectOptionMenu(
        editSubject: editSubject,
        editColor: editColor,
        deleteSubject: deleteSubject,
        testSubject: testSubject,
        animation: blurAnimation,
        index: currentFocused,
        editInfo: editClassroomInfo,
        studyCards: studyCards,
      );

  ImageFilter calculateBlur() {
    if (currentFocused != -1) {
      return ImageFilter.blur(
        sigmaX: 20 * blurAnimation.value,
        sigmaY: 20 * blurAnimation.value,
        tileMode: TileMode.decal,
      );
    } else {
      return ImageFilter.blur(
        sigmaX: 8 * (1 - enterAnimation.value),
        sigmaY: 8 * (1 - enterAnimation.value),
      );
    }
  }

  Widget buildSubjectsList() => AnimatedBuilder(
        animation: enterController,
        builder: (context, _) => GestureDetector(
          onTap: closeMenus,
          child: Stack(
            children: [
              ListView.builder(
                physics: const ScrollPhysics(),
                shrinkWrap: true,
                clipBehavior: Clip.none,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                itemCount: widget.subjects.length,
                itemBuilder: (context, index) => InkWell(
                  onTap: () async {
                    final wasOpen = controller.open;
                    await closeMenus();
                    if (currentFocused != -1 || wasOpen) {
                      return;
                    }
                    study(widget.subjects[index]);
                  },
                  onLongPress: () {
                    setState(() => currentFocused = index);
                    Future.delayed(Durations.short1, () => blurController.forward(from: 0));
                    closeMenus();
                  },
                  child: AnimatedBuilder(
                    animation: blurController,
                    builder: (_, __) => ImageFiltered(
                      imageFilter: calculateBlur(),
                      child: ScaleTransition(
                        scale: enterAnimation,
                        child: SubjectCard(subject: widget.subjects[index]),
                      ),
                    ),
                  ),
                ),
              ),
              if (currentFocused != -1) buildOptions(),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    enterController.forward();

    return Scaffold(
      appBar: buildAppBar(),
      floatingActionButton: buildFloatingActionButton(),
      body: GestureDetector(
        onTap: closeMenus,
        behavior: HitTestBehavior.translucent,
        child: widget.subjects.isEmpty ? buildPlaceholderText() : buildSubjectsList(),
      ),
    );
  }
}
