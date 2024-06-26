// ignore_for_file: use_build_context_synchronously

// ignore: unused_import
import 'dart:developer' as developer;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:studyappcs/data_managers/firestore_manager.dart' as firestore_manager;
import 'package:studyappcs/data_managers/tests_manager.dart' as tests_manager;
import 'package:studyappcs/pages/all_tests_page.dart';
import 'package:studyappcs/pages/study_page.dart';
import 'package:studyappcs/pages/subject_page.dart';
import 'package:studyappcs/pages/test_page.dart';
import 'package:studyappcs/states/flashcard.dart';
import 'package:studyappcs/states/subject.dart';
import 'package:studyappcs/states/test.dart';
import 'package:studyappcs/states/topic.dart';
import 'package:studyappcs/utils/expandable_fab.dart';
import 'package:studyappcs/utils/input_dialogs.dart';
import 'package:studyappcs/utils/utils.dart';
import 'package:studyappcs/widgets/subject_card.dart';
import 'package:studyappcs/widgets/subject_option_menu.dart';

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

    blurController = AnimationController(vsync: this, value: 0, duration: Durations.short4);

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
      currentFocused = -1;
    });
  }

  bool validateSubjectName(String str) {
    if (str.trim() == 'All') return false;

    if (getSubjectNames().contains(str)) {
      simpleSnackBar(context, 'Subject named $str already exists');

      return false;
    }

    return true;
  }

  void newSubject() async {
    closeMenus();

    String name = await singleInputDialog(
      context,
      'New Subject Name',
      Input(name: 'Name', validate: validateSubjectName),
    );

    if (name == '') return;

    Color? newColor = await showColorPicker(context, Colors.blue);
    if (newColor == null) return;

    DialogResult? res = await doubleInputDialog(
      context,
      'Choose teacher and classroom',
      Input(name: 'Teacher', nullable: true),
      Input(name: 'Classroom', nullable: true),
    );

    if (res == null) return;

    final subject = Subject(name, newColor, res.first, res.second);

    firestore_manager.subjectCollection.doc(subject.name).set({
      'name': subject.name,
      'scores': [],
      'color': newColor.value,
      'teacher': subject.teacher,
      'classroom': subject.classroom,
    });

    setState(() => widget.subjects.add(subject));
  }

  void deleteSubject() async {
    if (!await confirmDialog(context, title: 'Delete ${widget.subjects[currentFocused].name}')) return;

    String area = widget.subjects[currentFocused].asArea.trim();
    setState(() => widget.subjects.removeAt(currentFocused));
    tests_manager.pastTests.removeWhere((element) => element.area.trim() == area);

    var subject = await firestore_manager.subjectNamed(area);
    subject.reference.delete();

    var cards = await firestore_manager.cardsFromSubject(area);
    for (var a in cards) {
      a.reference.delete();
    }

    var tests = await firestore_manager.testDocs;
    tests.docs.where((a) => (a['area'] as String).contains(area)).forEach((a) => a.reference.delete());

    closeMenus();
  }

  void editColor() async {
    Color? newColor = await showColorPicker(context, widget.subjects[currentFocused].color);
    if (newColor == null) return;
    setState(() => widget.subjects[currentFocused].color = newColor);

    String name = widget.subjects[currentFocused].name;

    var subject = await firestore_manager.subjectNamed(name);
    subject.reference.update({'color': newColor.value});

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

  List<String> getSubjectNames() => List.generate(widget.subjects.length, (index) => widget.subjects[index].name);

  void editSubject() async {
    String newName = await singleInputDialog(
      context,
      'Rename ${widget.subjects[currentFocused].name}',
      Input(
        name: 'Name',
        validate: validateSubjectName,
      ),
    );

    if (newName == '') return;

    for (Test test in tests_manager.pastTests) {
      test.area = test.area.replaceAll(widget.subjects[currentFocused].name, newName);
    }

    String oldName = widget.subjects[currentFocused].name;

    var subject = await firestore_manager.subjectNamed(oldName);
    subject.reference.update({'name': newName});

    var docs = await firestore_manager.cardsFromSubject(oldName);
    for (var card in docs) {
      card.reference.update({'subject': newName});
    }

    setState(() => widget.subjects[currentFocused].name = newName);
    closeMenus();
  }

  void editSubjectInfo() async {
    DialogResult? res = await doubleInputDialog(
      context,
      'Choose teacher and classroom',
      Input(name: 'Teacher', nullable: true),
      Input(name: 'Classroom', nullable: true),
    );

    if (res == null) return;

    setState(() {
      widget.subjects[currentFocused].teacher = res.first;
      widget.subjects[currentFocused].classroom = res.second;
    });

    var subject = await firestore_manager.subjectNamed(widget.subjects[currentFocused].name);
    subject.reference.update({'teacher': res.first, 'classroom': res.second});
  }

  void clearSubjects() async {
    bool confirmed = await confirmDialog(
      context,
      title: 'Delete all Subjects',
    );

    if (!confirmed) return;

    var cardsCollection = firestore_manager.cardCollection;
    var cards = await cardsCollection.get();
    for (var a in cards.docs) {
      a.reference.delete();
    }

    var subjectCollection = firestore_manager.subjectCollection;
    var subjects = await subjectCollection.get();
    for (var a in subjects.docs) {
      a.reference.delete();
    }

    setState(() {
      widget.subjects.clear();
      currentFocused = -1;
    });

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
      MaterialPageRoute(builder: (_) => StudyPage(cards: cards, topic: Topic('All Subjects'))),
    );
  }

  void testAll() {
    List<TestCard> cards = [];
    for (Subject subject in widget.subjects) {
      for (Topic topic in subject.topics) {
        for (FlashCard card in topic.cards) {
          cards.add(TestCard(card.name, card.name, '${subject.name} - ${topic.name}'));
        }
      }
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => TestPage(cards: cards, testArea: 'All')));
  }

  void showAllTests() {
    closeMenus();
    Navigator.push(context, MaterialPageRoute(builder: (_) => const AllTestsPage()));
  }

  @override
  Widget build(BuildContext context) {
    enterController.forward();

    Widget fab = ExpandableFab(
      controller: controller,
      onPress: () async {
        await blurController.reverse(from: 1);
        setState(() => currentFocused = -1);
      },
      children: [
        ActionButton(onPressed: newSubject, icon: const Icon(Icons.add_rounded), name: 'New Subject'),
        if (widget.subjects.isNotEmpty) ...[
          ActionButton(onPressed: clearSubjects, icon: const Icon(Icons.delete_rounded), name: 'Clear Subjects'),
          ActionButton(onPressed: studyAll, icon: const Icon(Icons.school_rounded), name: 'Study All'),
          ActionButton(onPressed: testAll, icon: const Icon(Icons.question_mark_rounded), name: 'Test All'),
        ],
      ],
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.history_rounded),
          onPressed: tests_manager.pastTests.isNotEmpty ? showAllTests : null,
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
                    'No Subjects.\nExpand the menu and\npress + to make a new subject. ',
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
                          if (currentFocused != -1) {
                            blurController.reverse(from: 1).then((_) => setState(() => currentFocused = -1));
                            return;
                          }
                          study(widget.subjects[index]);
                        },
                        onLongPress: () {
                          setState(() => currentFocused = index);
                          //TODO option menu fixing cus its ugly
                          //TODO clean up other stuff or something
                          Future.delayed(Durations.short1, () => blurController.forward(from: 0));
                        },
                        child: AnimatedBuilder(
                          animation: blurController,
                          builder: (_, __) => ImageFiltered(
                            imageFilter: (currentFocused != -1)
                                ? ImageFilter.blur(
                                    sigmaX: 20 * blurAnimation.value,
                                    sigmaY: 20 * blurAnimation.value,
                                    tileMode: TileMode.decal,
                                  )
                                : ImageFilter.blur(
                                    sigmaX: 8 * (1 - enterAnimation.value),
                                    sigmaY: 8 * (1 - enterAnimation.value),
                                  ),
                            child: SubjectCard(subject: widget.subjects[index], width: enterAnimation.value * 3),
                          ),
                        ),
                      ),
                    ),
                    if (currentFocused != -1)
                      SubjectOptionMenu(
                        editSubject: editSubject,
                        editColor: editColor,
                        deleteSubject: deleteSubject,
                        testSubject: testSubject,
                        animation: blurAnimation,
                        index: currentFocused,
                        editInfo: editSubjectInfo,
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
