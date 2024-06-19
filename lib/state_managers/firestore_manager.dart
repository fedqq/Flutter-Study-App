import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:studyappcs/state_managers/statistics.dart';
import 'package:studyappcs/state_managers/tests_manager.dart';
import 'package:studyappcs/states/flashcard.dart';
import 'package:studyappcs/states/subject.dart';
import 'package:studyappcs/states/task.dart';
import 'package:studyappcs/states/test.dart';
import 'package:studyappcs/states/topic.dart';

typedef SnapshotType = Future<QuerySnapshot<Map<String, dynamic>>>;
typedef CollectionType = CollectionReference<Map<String, dynamic>>;
SetOptions merge = SetOptions(merge: true);

abstract class FirestoreManager {
  static DocumentReference getUser() {
    User? user = FirebaseAuth.instance.currentUser;
    final db = FirebaseFirestore.instance;
    CollectionReference users = db.collection('users');
    DocumentReference currentUser = users.doc(user?.uid);
    return currentUser;
  }

  static CollectionType get subjectCollection => getUser().collection('subjects');
  static CollectionType get cardCollection => getUser().collection('cards');
  static CollectionType get taskCollection => getUser().collection('tasks');
  static CollectionType get testCollection => getUser().collection('tests');

  static SnapshotType get subjectDocs async => await subjectCollection.get();
  static SnapshotType get cardDocs async => await cardCollection.get();
  static SnapshotType get taskDocs async => await taskCollection.get();
  static SnapshotType get testDocs async => await testCollection.get();

  static List<Subject> subjectsList = [];
  static List<Task> tasksList = [];
  static List<Task> compTasksList = [];

  static void _userpref(Map<String, dynamic> v) => getUser().set(v, merge);

  static set goal(String goal) => _userpref({'goal': int.tryParse(goal)});
  static set username(String name) => _userpref({'username': name});
  static set color(int color) => _userpref({'color': color});
  static set lightness(bool l) => _userpref({'lightness': l});
  static set streaks(Map s) => getUser().set({'streaks': s}, merge);
  static set studied(Map s) => getUser().set({'studied': s}, merge);

  static Future<void> loadData() async {
    var currentUser = getUser();

    final prefs = (await currentUser.get()).data() as Map<String, dynamic>?;
    //name, goal, color, lightness, streaks, studied
    if (prefs == null) return;
    String name = prefs['username'] as String;
    int goal = prefs['goal'] as int;
    int accentColor = prefs['color'] as int;
    bool lightness = prefs['lightness'] as bool;
    Map<String, int> streaks = (prefs['streaks'] as Map<String, dynamic>).cast<String, int>();
    Map<String, int> studied = (prefs['studied'] as Map<String, dynamic>).cast<String, int>();

    StudyStatistics.userName = name;
    StudyStatistics.color = Color(accentColor);
    StudyStatistics.lightness = lightness;
    StudyStatistics.dailyGoal = goal;
    StudyStatistics.dailyStreak = streaks;
    StudyStatistics.dailyStudied = studied;

    List<Subject> subjects = [];

    final subjectsCol = await subjectDocs;
    for (var snapshot in subjectsCol.docs) {
      final data = snapshot.data();
      String name = data['name'] as String;
      List<int> scores = (data['scores'] as List).cast<int>();
      Color subjectColor = Color(data['color'] as int);
      Subject subject = Subject(name, subjectColor);
      subject.testScores = scores;
      subjects.add(subject);
    }

    final cardsCol = await cardDocs;
    for (var snapshot in cardsCol.docs) {
      final data = snapshot.data();
      String subjectName = data['subject'] as String;
      String topicName = data['topic'] as String;
      String name = data['name'] as String;
      String meaning = data['meaning'] as String;
      bool learned = data['learned'] as bool;
      FlashCard card = FlashCard(name, meaning, learned);
      Subject realSubject = subjects.firstWhere((s) => s.name == subjectName);

      realSubject.topics
          .firstWhere((t) => t.name == topicName, orElse: () => realSubject.addTopic(Topic(topicName)))
          .addCard(card);
    }

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

      (completed ? completedTasks : tasks).add(Task(name, dueDate, completed, taskColor, desc));
    }

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
    TestsManager.pastTests = tests;

    subjectsList = subjects;
    tasksList = tasks;
    compTasksList = completedTasks;
  }

  static Future<void> saveData() async {
    var currentUser = getUser();

    currentUser.set({
      'username': StudyStatistics.userName,
      'goal': StudyStatistics.dailyGoal,
      'color': StudyStatistics.color.value,
      'lightness': StudyStatistics.lightness,
      'streaks': StudyStatistics.dailyStreak,
      'studied': StudyStatistics.dailyStudied
    });
  }
}
