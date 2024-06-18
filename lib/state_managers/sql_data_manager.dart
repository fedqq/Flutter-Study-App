import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:studyappcs/states/flashcard.dart';
import 'package:studyappcs/states/subject.dart';
import 'package:studyappcs/states/task.dart';
import 'package:studyappcs/states/topic.dart';

abstract class SQLManager {
  static Future clearAll() async {
    final db = await getDatabase();
    await db.execute('DELETE FROM tasks');
    await db.execute('DELETE FROM donetask');
    await db.execute('DELETE FROM subjects');
  }

  static Future<Database> getDatabase() async {
    final path = await getDatabasesPath();
    final database = openDatabase(
      '$path/maindata_db.db',
      onCreate: (db, version) {
        db.execute('CREATE TABLE subjects(name TEXT PRIMARY KEY, color INT, scores TEXT)');
        db.execute('CREATE TABLE tasks(name TEXT PRIMARY KEY, date STRING, completed BOOL, color INT, desc STRING)');
        db.execute('CREATE TABLE donetask(name TEXT PRIMARY KEY, date STRING, completed BOOL, color INT, desc STRING)');
        db.execute(
            'CREATE TABLE cards(name TEXT, meaning TEXT, learned BOOL, subject TEXT, topic TEXT, id INT PRIMARY KEY)');
      },
      version: 1,
    );
    return await database;
  }

  static Future saveData(List<Subject> subjects, List<Task> tasks, List<Task> completedTasks) async {
    final db = await getDatabase();

    await db.execute('DELETE FROM tasks');
    await db.execute('DELETE FROM donetask');
    await db.execute('DELETE FROM subjects');
    await db.execute('DELETE FROM cards');

    int i = 0;
    for (Subject subject in subjects) {
      for (Topic topic in subject.topics) {
        for (FlashCard card in topic.cards) {
          await db.insert('cards', {
            'name': card.name,
            'meaning': card.meaning,
            'learned': card.learned ? 1 : 0,
            'subject': subject.name,
            'topic': topic.name,
            'id': i
          });
          i++;
        }
      }
      await db.insert('subjects', subject.toMap());
    }

    for (Task task in tasks) {
      await db.insert('tasks', task.toMap());
    }

    for (Task task in completedTasks) {
      await db.insert('donetask', task.toMap());
    }
  }

  static Future<List<Subject>> loadSubjects() async {
    List<Subject> res = [];
    final db = await getDatabase();
    final data = await db.rawQuery('SELECT * FROM subjects');
    for (var entry in data) {
      Color col = Color(entry['color'] as int);
      String name = entry['name'] as String;
      Subject obj = Subject(name, col);
      obj.testScores = (entry['scores'] as String).split(',').cast<int>();
      res.add(obj);
    }

    final cards = await db.rawQuery('SELECT * FROM cards');
    for (var entry in cards) {
      String name = entry['name'] as String;
      String meaning = entry['meaning'] as String;
      String subject = entry['subject'] as String;
      String topic = entry['topic'] as String;
      bool learned = entry['learned'] as bool;

      FlashCard card = FlashCard(name, meaning, learned);
      Subject realSubject = res.firstWhere((s) => s.name == subject);

      realSubject.topics
          .firstWhere((t) => t.name == topic, orElse: () => realSubject.addTopic(Topic(topic)))
          .addCard(card);
    }
    return res;
  }

  static Future<List<Task>> loadTasks() async {
    final db = await getDatabase();
    List<Task> res = [];
    final data = await db.rawQuery('SELECT * FROM tasks');
    for (var entry in data) {
      res.add(Task(
        entry['name'] as String,
        DateTime.fromMillisecondsSinceEpoch(entry['date'] as int),
        (entry['completed'] as int) == 0 ? false : true,
        Color(entry['color'] as int),
        entry['desc'] as String,
      ));
    }

    return res;
  }

  static Future<List<Task>> loadCompletedTasks() async {
    final db = await getDatabase();
    List<Task> res = [];
    final data = await db.rawQuery('SELECT * FROM donetask');
    for (var entry in data) {
      res.add(Task(
        entry['name'] as String,
        DateTime.fromMillisecondsSinceEpoch(entry['date'] as int),
        (entry['completed'] as int) == 0 ? false : true,
        Color(entry['color'] as int),
        entry['desc'] as String,
      ));
    }

    return res;
  }
}
