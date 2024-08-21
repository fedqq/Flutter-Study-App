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

DocumentReference<StrMap> get _user {
  final user = FirebaseAuth.instance.currentUser;
  final db = FirebaseFirestore.instance;
  final users = db.collection('users');
  final currentUser = users.doc(user?.uid);
  return currentUser;
}

Collection get subjectCollection => _user.collection('subjects');
Collection get cardCollection => _user.collection('cards');
Collection get taskCollection => _user.collection('tasks');
Collection get testCollection => _user.collection('tests');

SnapShotFuture get subjectDocs async => subjectCollection.get();
SnapShotFuture get cardDocs async => cardCollection.get();
SnapShotFuture get taskDocs async => taskCollection.get();
SnapShotFuture get testDocs async => testCollection.get();

List<Subject> subjectsList = <Subject>[];
List<Task> tasksList = <Task>[];
List<Task> compTasksList = <Task>[];

void _setUserPref(StrMap v) => _user.update(v);

set goal(int goal) => _setUserPref({'goal': goal});
set username(String name) => _setUserPref({'username': name});
set color(int color) => _setUserPref({'color': color});
// ignore: avoid_positional_boolean_parameters
set lightness(bool l) => _setUserPref({'lightness': l});
set streaks(StrMap s) => _user.update({'streaks': s});
set studied(StrMap s) => _user.update({'studied': s});

Future<List<DocSnapshot>> cardsFromSubject(String s) async =>
    (await cardCollection.where('subject', isEqualTo: s).get()).docs;

Future<List<DocSnapshot>> cardsFromTopic(String t) async =>
    (await cardCollection.where('topic', isEqualTo: t).get()).docs;

DocSnapshotFuture cardNamed(String n) async => (await cardCollection.where('name', isEqualTo: n).get()).docs.first;

DocSnapshotFuture subjectNamed(String n) async =>
    (await subjectCollection.where('name', isEqualTo: n).get()).docs.first;

Future<void> _loadPrefs() async {
  final prefs = (await _user.get()).data();
  if (prefs == null) {
    return;
  }
  final name = prefs['username'] as String;
  final goal = prefs['goal'] as int;
  final accentColor = Color(prefs['color'] as int);
  final lightness = prefs['lightness'] as bool;
  final streaks = (prefs['streaks'] as StrMap).cast<String, int>();
  final studied = (prefs['studied'] as StrMap).cast<String, int>();
  final lastTestID = prefs['id'] as int;

  user_data.userName = name;
  user_data.color = accentColor;
  user_data.lightness = lightness;
  user_data.dailyGoal = goal;
  user_data.dailyStreak = streaks;
  user_data.dailyStudied = studied;
  tests_manager.id = lastTestID;
}

Future<void> loadData() async {
  final subjects = <Subject>[];

  await _loadPrefs();
  await _loadSubjects(subjects);
  await _loadCards(subjects);
  await _loadTasks();
  await _loadTests();

  subjectsList = subjects;
}

Future<void> _loadTests() async {
  final tests = <Test>[];
  final testsCol = await testDocs;
  for (final snapshot in testsCol.docs) {
    final data = snapshot.data();
    final String area = data['area'];
    final String date = data['date'];
    final int id = data['id'] ?? 0;
    final scored = <TestCard, bool>{};
    final answers = <String>[];

    final docs = await snapshot.reference.collection('testcards').get();
    for (final r in docs.docs) {
      final String name = r['name'];
      final String meaning = r['meaning'];
      final String given = r['given'];
      final correct = meaning == given;
      final String origin = r['origin'];
      scored[TestCard(name, meaning, origin)] = correct;
      answers.add(given);
    }

    tests.add(Test(scored, date, area, answers, id));
  }
  tests_manager.pastTests = tests;
}

Future<void> _loadTasks() async {
  final completedTasks = <Task>[];
  final tasks = <Task>[];

  final tasksCol = await taskDocs;
  for (final snapshot in tasksCol.docs) {
    final data = snapshot.data();
    final name = data['name'] as String;
    final desc = data['desc'] as String;
    final completed = data['completed'] as bool;
    final taskColor = Color(data['color'] as int);
    final dueDate = DateTime.fromMillisecondsSinceEpoch(data['date'] as int);

    (completed ? completedTasks : tasks).add(Task(name, dueDate, taskColor, desc, completed: completed));
  }

  tasksList = tasks;
  compTasksList = completedTasks;
}

Future<void> _loadCards(List<Subject> subjects) async {
  final cardsCol = await cardDocs;
  for (final snapshot in cardsCol.docs) {
    final data = snapshot.data();
    final subjectName = data['subject'] as String;
    final topicName = data['topic'] as String;
    final name = data['name'] as String;
    final meaning = data['meaning'] as String;
    final learned = data['learned'] as bool;
    final card = FlashCard(name, meaning, learned: learned);

    final realSubject = subjects.firstWhere((s) => s.name == subjectName);

    realSubject.topics
        .firstWhere((t) => t.name == topicName, orElse: () => realSubject.addTopic(Topic(topicName)))
        .addCard(card);
  }
}

Future<void> _loadSubjects(List<Subject> subjects) async {
  final subjectsCol = await subjectDocs;
  for (final snapshot in subjectsCol.docs) {
    final data = snapshot.data();
    final name = data['name'] as String;
    final scores = (data['scores'] as List<dynamic>).cast<int>();
    final subjectColor = Color(data['color'] as int);
    final teacher = (data['teacher'] as String?) ?? '';
    final classroom = (data['classroom'] as String?) ?? '';
    final subject = Subject(name, subjectColor, teacher, classroom)..testScores = scores;
    subjects.add(subject);
  }
}

Future<void> saveData() async => _user.set(<String, Object>{
      'username': user_data.userName,
      'goal': user_data.dailyGoal,
      'color': user_data.color.value,
      'lightness': user_data.lightness,
      'streaks': user_data.dailyStreak,
      'studied': user_data.dailyStudied,
      'id': tests_manager.id,
    });
