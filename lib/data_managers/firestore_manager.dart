import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:studyappcs/data_managers/tests_manager.dart' as tests_manager;
import 'package:studyappcs/data_managers/user_data.dart' as user_data;
import 'package:studyappcs/states/flashcard.dart';
import 'package:studyappcs/states/subject.dart';
import 'package:studyappcs/states/task.dart';
import 'package:studyappcs/states/test.dart';
import 'package:studyappcs/states/topic.dart';
import 'package:studyappcs/utils/utils.dart';

typedef SnapshotType = Future<QuerySnapshot<StrMap>>;
typedef DocSnapshotType = Future<QueryDocumentSnapshot<StrMap>>;
typedef CollectionType = CollectionReference<StrMap>;

DocumentReference<StrMap> get _user {
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final CollectionReference<StrMap> users = db.collection('users');
  final DocumentReference<StrMap> currentUser = users.doc(user?.uid);
  return currentUser;
}

CollectionType get subjectCollection => _user.collection('subjects');
CollectionType get cardCollection => _user.collection('cards');
CollectionType get taskCollection => _user.collection('tasks');
CollectionType get testCollection => _user.collection('tests');

SnapshotType get subjectDocs async => subjectCollection.get();
SnapshotType get cardDocs async => cardCollection.get();
SnapshotType get taskDocs async => taskCollection.get();
SnapshotType get testDocs async => testCollection.get();

List<Subject> subjectsList = <Subject>[];
List<Task> tasksList = <Task>[];
List<Task> compTasksList = <Task>[];

void _userpref(StrMap v) => _user.update(v);

set goal(String goal) => _userpref(<String, dynamic>{'goal': int.tryParse(goal)});
set username(String name) => _userpref(<String, dynamic>{'username': name});
set color(int color) => _userpref(<String, dynamic>{'color': color});
// ignore: avoid_positional_boolean_parameters
set lightness(bool l) => _userpref(<String, dynamic>{'lightness': l});
set streaks(StrMap s) => _user.update(<Object, Object?>{'streaks': s});
set studied(StrMap s) => _user.update(<Object, Object?>{'studied': s});

Future<List<QueryDocumentSnapshot<StrMap>>> cardsFromSubject(String s) async =>
    (await cardCollection.where('subject', isEqualTo: s).get()).docs;

Future<List<QueryDocumentSnapshot<StrMap>>> cardsFromTopic(String t) async =>
    (await cardCollection.where('topic', isEqualTo: t).get()).docs;

DocSnapshotType cardNamed(String n) async => (await cardCollection.where('name', isEqualTo: n).get()).docs.first;

DocSnapshotType subjectNamed(String n) async => (await subjectCollection.where('name', isEqualTo: n).get()).docs.first;

Future<void> _loadPrefs() async {
  final StrMap? prefs = (await _user.get()).data();
  if (prefs == null) {
    return;
  }
  final String name = prefs['username'] as String;
  final int goal = prefs['goal'] as int;
  final int accentColor = prefs['color'] as int;
  final bool lightness = prefs['lightness'] as bool;
  final Map<String, int> streaks = (prefs['streaks'] as StrMap).cast<String, int>();
  final Map<String, int> studied = (prefs['studied'] as StrMap).cast<String, int>();

  user_data.userName = name;
  user_data.color = Color(accentColor);
  user_data.lightness = lightness;
  user_data.dailyGoal = goal;
  user_data.dailyStreak = streaks;
  user_data.dailyStudied = studied;
}

Future<void> loadData() async {
  final List<Subject> subjects = <Subject>[];

  await _loadPrefs();
  await _loadSubjects(subjects);
  await _loadCards(subjects);
  await _loadTasks();
  await _loadTests();

  subjectsList = subjects;
}

Future<void> _loadTests() async {
  final List<Test> tests = <Test>[];
  final QuerySnapshot<StrMap> testsCol = await testDocs;
  for (final QueryDocumentSnapshot<StrMap> snapshot in testsCol.docs) {
    final StrMap data = snapshot.data();
    final String area = data['area'];
    final String date = data['date'];
    final int id = data['id'] ?? 0;
    final Map<TestCard, bool> scored = <TestCard, bool>{};
    final List<String> answers = <String>[];

    final QuerySnapshot<StrMap> docs = await snapshot.reference.collection('testcards').get();
    for (final QueryDocumentSnapshot<StrMap> r in docs.docs) {
      final String name = r['name'];
      final String meaning = r['meaning'];
      final String given = r['given'];
      final bool correct = meaning == given;
      final String origin = r['origin'];
      scored[TestCard(name, meaning, origin)] = correct;
      answers.add(given);
    }

    tests.add(Test(scored, date, area, answers, id));
  }
  tests_manager.pastTests = tests;
}

Future<void> _loadTasks() async {
  final List<Task> completedTasks = <Task>[];
  final List<Task> tasks = <Task>[];

  final QuerySnapshot<StrMap> tasksCol = await taskDocs;
  for (final QueryDocumentSnapshot<StrMap> snapshot in tasksCol.docs) {
    final StrMap data = snapshot.data();
    final String name = data['name'] as String;
    final String desc = data['desc'] as String;
    final bool completed = data['completed'] as bool;
    final Color taskColor = Color(data['color'] as int);
    final DateTime dueDate = DateTime.fromMillisecondsSinceEpoch(data['date'] as int);

    (completed ? completedTasks : tasks).add(Task(name, dueDate, taskColor, desc, completed: completed));
  }

  tasksList = tasks;
  compTasksList = completedTasks;
}

Future<void> _loadCards(List<Subject> subjects) async {
  final QuerySnapshot<StrMap> cardsCol = await cardDocs;
  for (final QueryDocumentSnapshot<StrMap> snapshot in cardsCol.docs) {
    final StrMap data = snapshot.data();
    final String subjectName = data['subject'] as String;
    final String topicName = data['topic'] as String;
    final String name = data['name'] as String;
    final String meaning = data['meaning'] as String;
    final bool learned = data['learned'] as bool;
    final FlashCard card = FlashCard(name, meaning, learned: learned);

    final Subject realSubject = subjects.firstWhere((Subject s) => s.name == subjectName);

    realSubject.topics
        .firstWhere((Topic t) => t.name == topicName, orElse: () => realSubject.addTopic(Topic(topicName)))
        .addCard(card);
  }
}

Future<void> _loadSubjects(List<Subject> subjects) async {
  final QuerySnapshot<StrMap> subjectsCol = await subjectDocs;
  for (final QueryDocumentSnapshot<StrMap> snapshot in subjectsCol.docs) {
    final StrMap data = snapshot.data();
    final String name = data['name'] as String;
    final List<int> scores = data['scores'] as List<int>;
    final Color subjectColor = Color(data['color'] as int);
    final String teacher = (data['teacher'] as String?) ?? '';
    final String classroom = (data['classroom'] as String?) ?? '';
    final Subject subject = Subject(name, subjectColor, teacher, classroom)..testScores = scores;
    subjects.add(subject);
  }
}

Future<void> saveData() async {
  await _user.set(<String, Object>{
    'username': user_data.userName,
    'goal': user_data.dailyGoal,
    'color': user_data.color.value,
    'lightness': user_data.lightness,
    'streaks': user_data.dailyStreak,
    'studied': user_data.dailyStudied,
  });
}
