import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:studyappcs/data_managers/user_data.dart' as user_data;
import 'package:studyappcs/data_managers/tests_manager.dart' as tests_manager;
import 'package:studyappcs/states/flashcard.dart';
import 'package:studyappcs/states/subject.dart';
import 'package:studyappcs/states/task.dart';
import 'package:studyappcs/states/test.dart';
import 'package:studyappcs/states/topic.dart';

typedef SnapshotType = Future<QuerySnapshot<Map<String, dynamic>>>;
typedef DocSnapshotType = Future<QueryDocumentSnapshot<Map<String, dynamic>>>;
typedef CollectionType = CollectionReference<Map<String, dynamic>>;

DocumentReference get _user {
  User? user = FirebaseAuth.instance.currentUser;
  final db = FirebaseFirestore.instance;
  CollectionReference users = db.collection('users');
  DocumentReference currentUser = users.doc(user?.uid);
  return currentUser;
}

CollectionType get subjectCollection => _user.collection('subjects');
CollectionType get cardCollection => _user.collection('cards');
CollectionType get taskCollection => _user.collection('tasks');
CollectionType get testCollection => _user.collection('tests');

SnapshotType get subjectDocs async => await subjectCollection.get();
SnapshotType get cardDocs async => await cardCollection.get();
SnapshotType get taskDocs async => await taskCollection.get();
SnapshotType get testDocs async => await testCollection.get();

List<Subject> subjectsList = [];
List<Task> tasksList = [];
List<Task> compTasksList = [];

void _userpref(Map<String, dynamic> v) => _user.update(v);

set goal(String goal) => _userpref({'goal': int.tryParse(goal)});
set username(String name) => _userpref({'username': name});
set color(int color) => _userpref({'color': color});
// ignore: avoid_positional_boolean_parameters
set lightness(bool l) => _userpref({'lightness': l});
set streaks(Map s) => _user.update({'streaks': s});
set studied(Map s) => _user.update({'studied': s});

Future<List<QueryDocumentSnapshot>> cardsFromSubject(String s) async =>
    (await cardCollection.where('subject', isEqualTo: s).get()).docs;

Future<List<QueryDocumentSnapshot>> cardsFromTopic(String t) async =>
    (await cardCollection.where('topic', isEqualTo: t).get()).docs;

DocSnapshotType cardNamed(String n) async => (await cardCollection.where('name', isEqualTo: n).get()).docs.first;

DocSnapshotType subjectNamed(String n) async => (await subjectCollection.where('name', isEqualTo: n).get()).docs.first;

Future<void> _loadPrefs() async {
  final prefs = (await _user.get()).data() as Map<String, dynamic>?;
  if (prefs == null) return;
  String name = prefs['username'] as String;
  int goal = prefs['goal'] as int;
  int accentColor = prefs['color'] as int;
  bool lightness = prefs['lightness'] as bool;
  Map<String, int> streaks = (prefs['streaks'] as Map<String, dynamic>).cast<String, int>();
  Map<String, int> studied = (prefs['studied'] as Map<String, dynamic>).cast<String, int>();

  user_data.userName = name;
  user_data.color = Color(accentColor);
  user_data.lightness = lightness;
  user_data.dailyGoal = goal;
  user_data.dailyStreak = streaks;
  user_data.dailyStudied = studied;
}

Future<void> loadData() async {
  List<Subject> subjects = [];

  await _loadPrefs();
  await _loadSubjects(subjects);
  await _loadCards(subjects);
  await _loadTasks();
  await _loadTests();

  subjectsList = subjects;
}

Future<void> _loadTests() async {
  List<Test> tests = [];
  final testsCol = await testDocs;
  for (var snapshot in testsCol.docs) {
    final data = snapshot.data();
    String area = data['area'];
    String date = data['date'];
    int id = data['id'] ?? 0;
    final Map<TestCard, bool> scored = {};
    final List<String> answers = [];

    var docs = await snapshot.reference.collection('testcards').get();
    for (var r in docs.docs) {
      String name = r['name'];
      String meaning = r['meaning'];
      String given = r['given'];
      bool correct = meaning == given;
      String origin = r['origin'];
      scored[TestCard(name, meaning, origin)] = correct;
      answers.add(given);
    }

    tests.add(Test(scored, date, area, answers, id));
  }
  tests_manager.pastTests = tests;
}

Future<void> _loadTasks() async {
  List<Task> completedTasks = [];
  List<Task> tasks = [];

  final tasksCol = await taskDocs;
  for (var snapshot in tasksCol.docs) {
    final data = snapshot.data();
    String name = data['name'] as String;
    String desc = data['desc'] as String;
    bool completed = data['completed'] as bool;
    Color taskColor = Color(data['color'] as int);
    DateTime dueDate = DateTime.fromMillisecondsSinceEpoch(data['date'] as int);

    (completed ? completedTasks : tasks).add(Task(name, dueDate, taskColor, desc, completed: completed));
  }

  tasksList = tasks;
  compTasksList = completedTasks;
}

Future<void> _loadCards(List<Subject> subjects) async {
  final cardsCol = await cardDocs;
  for (var snapshot in cardsCol.docs) {
    final data = snapshot.data();
    String subjectName = data['subject'] as String;
    String topicName = data['topic'] as String;
    String name = data['name'] as String;
    String meaning = data['meaning'] as String;
    bool learned = data['learned'] as bool;
    FlashCard card = FlashCard(name, meaning, learned: learned);

    Subject realSubject = subjects.firstWhere((s) => s.name == subjectName);

    realSubject.topics
        .firstWhere((t) => t.name == topicName, orElse: () => realSubject.addTopic(Topic(topicName)))
        .addCard(card);
  }
}

Future<void> _loadSubjects(List<Subject> subjects) async {
  final subjectsCol = await subjectDocs;
  for (var snapshot in subjectsCol.docs) {
    final data = snapshot.data();
    String name = data['name'] as String;
    List<int> scores = (data['scores'] as List).cast<int>();
    Color subjectColor = Color(data['color'] as int);
    String teacher = (data['teacher'] as String?) ?? '';
    String classroom = (data['classroom'] as String?) ?? '';
    Subject subject = Subject(name, subjectColor, teacher, classroom)..testScores = scores;
    subjects.add(subject);
  }
}

Future<void> saveData() async {
  _user.set({
    'username': user_data.userName,
    'goal': user_data.dailyGoal,
    'color': user_data.color.value,
    'lightness': user_data.lightness,
    'streaks': user_data.dailyStreak,
    'studied': user_data.dailyStudied,
  });
}
