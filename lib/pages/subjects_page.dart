// ignore_for_file: use_build_context_synchronously, always_specify_types

// ignore: unused_import
import 'dart:developer' as developer;
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<void> closeMenus() async {
    await blurController.reverse(from: 1);
    setState(() {
      currentFocused = -1;
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

    final String name = await singleInputDialog(
      context,
      'New Subject Name',
      Input(name: 'Name', validate: validateSubjectName),
    );

    if (name == '') {
      return;
    }

    final Color? newColor = await showColorPicker(context, Colors.blue);
    if (newColor == null) {
      return;
    }

    final DialogResult? res = await doubleInputDialog(
      context,
      'Choose teacher and classroom',
      Input(name: 'Teacher', nullable: true),
      Input(name: 'Classroom', nullable: true),
    );

    if (res == null) {
      return;
    }

    final Subject subject = Subject(name, newColor, res.first, res.second);

    await firestore_manager.subjectCollection.doc(subject.name).set(<String, dynamic>{
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

    final String area = widget.subjects[currentFocused].asArea.trim();
    setState(() => widget.subjects.removeAt(currentFocused));
    tests_manager.pastTests.removeWhere((Test element) => element.area.trim() == area);

    final QueryDocumentSnapshot<StrMap> subject = await firestore_manager.subjectNamed(area);
    await subject.reference.delete();

    final List<QueryDocumentSnapshot<StrMap>> cards = await firestore_manager.cardsFromSubject(area);
    for (final QueryDocumentSnapshot<StrMap> a in cards) {
      await a.reference.delete();
    }

    final QuerySnapshot<StrMap> tests = await firestore_manager.testDocs;
    tests.docs
        .where((QueryDocumentSnapshot<StrMap> a) => (a['area'] as String).contains(area))
        .forEach((QueryDocumentSnapshot<StrMap> a) => a.reference.delete());

    await closeMenus();
  }

  Future<void> editColor() async {
    final Color? newColor = await showColorPicker(context, widget.subjects[currentFocused].color);
    if (newColor == null) {
      return;
    }
    setState(() => widget.subjects[currentFocused].color = newColor);

    final String name = widget.subjects[currentFocused].name;

    final QueryDocumentSnapshot<StrMap> subject = await firestore_manager.subjectNamed(name);
    await subject.reference.update(<Object, Object?>{'color': newColor.value});

    await closeMenus();
  }

  Future<void> testSubject() async {
    final List<TestCard> cards = <TestCard>[];
    final Subject subject = widget.subjects[currentFocused];
    for (final Topic topic in subject.topics) {
      for (final FlashCard card in topic.cards) {
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

  List<String> getSubjectNames() =>
      List<String>.generate(widget.subjects.length, (int index) => widget.subjects[index].name);

  Future<void> editSubject() async {
    final String newName = await singleInputDialog(
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

    for (final Test test in tests_manager.pastTests) {
      test.area = test.area.replaceAll(widget.subjects[currentFocused].name, newName);
    }

    final String oldName = widget.subjects[currentFocused].name;

    final QueryDocumentSnapshot<StrMap> subject = await firestore_manager.subjectNamed(oldName);
    await subject.reference.update(<Object, Object?>{'name': newName});

    final List<QueryDocumentSnapshot<StrMap>> docs = await firestore_manager.cardsFromSubject(oldName);
    for (final QueryDocumentSnapshot<StrMap> card in docs) {
      await card.reference.update(<Object, Object?>{'subject': newName});
    }

    setState(() => widget.subjects[currentFocused].name = newName);
    await closeMenus();
  }

  Future<void> editSubjectInfo() async {
    final DialogResult? res = await doubleInputDialog(
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

    final QueryDocumentSnapshot<StrMap> subject =
        await firestore_manager.subjectNamed(widget.subjects[currentFocused].name);
    await subject.reference.update(<Object, Object?>{'teacher': res.first, 'classroom': res.second});
  }

  Future<void> clearSubjects() async {
    final bool confirmed = await confirmDialog(
      context,
      title: 'Delete all Subjects',
    );

    if (!confirmed) {
      return;
    }

    final firestore_manager.CollectionType cardsCollection = firestore_manager.cardCollection;
    final QuerySnapshot<StrMap> cards = await cardsCollection.get();
    for (final QueryDocumentSnapshot<StrMap> a in cards.docs) {
      await a.reference.delete();
    }

    final firestore_manager.CollectionType subjectCollection = firestore_manager.subjectCollection;
    final QuerySnapshot<StrMap> subjects = await subjectCollection.get();
    for (final QueryDocumentSnapshot<StrMap> a in subjects.docs) {
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

    List<FlashCard> cards = <FlashCard>[];
    for (final Subject subject in widget.subjects) {
      for (final Topic topic in subject.topics) {
        cards += topic.cards;
      }
    }
    if (cards.isEmpty) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => StudyPage(cards: cards, topic: Topic('All Subjects'))),
    );
  }

  void testAll() {
    final List<TestCard> cards = <TestCard>[];
    for (final Subject subject in widget.subjects) {
      for (final Topic topic in subject.topics) {
        for (final FlashCard card in topic.cards) {
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

    final Widget fab = ExpandableFab(
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
          builder: (BuildContext context, _) => widget.subjects.isEmpty
              ? const Center(
                  child: Text(
                    'No Subjects.\nExpand the menu and\npress + to make a new subject. ',
                    textAlign: TextAlign.center,
                  ),
                )
              : Stack(
                  children: <Widget>[
                    ListView.builder(
                      physics: const ScrollPhysics(),
                      shrinkWrap: true,
                      clipBehavior: Clip.none,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      itemCount: widget.subjects.length,
                      itemBuilder: (BuildContext context, int index) => InkWell(
                        onTap: () async {
                          if (currentFocused != -1) {
                            await blurController.reverse(from: 1).then((_) => setState(() => currentFocused = -1));
                            return;
                          }
                          study(widget.subjects[index]);
                        },
                        onLongPress: () {
                          setState(() => currentFocused = index);
                          //TODO option menu fixing cus its ugly
                          //TODO clean up other stuff or something
                          Future<void>.delayed(Durations.short1, () => blurController.forward(from: 0));
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
