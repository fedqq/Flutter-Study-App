import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:studyappcs/states/subject.dart';
import 'package:studyappcs/states/task.dart';
import 'package:studyappcs/states/topic.dart';

abstract class SQLManager {
  static Future clearAll() async {
    //TODO clear all
  }

  static Future<Database> getDatabase() async {
    final path = await getDatabasesPath();
    final database = openDatabase(
      '$path/maindata_db.db',
      onCreate: (db, version) {
        db.execute('CREATE TABLE subjects(name TEXT PRIMARY KEY, color INT, scores TEXT, topics TEXT)');
        db.execute('CREATE TABLE tasks(name TEXT PRIMARY KEY, date STRING, completed BOOL, color INT, desc STRING)');
        db.execute('CREATE TABLE donetask(name TEXT PRIMARY KEY, date STRING, completed BOOL, color INT, desc STRING)');
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

    for (Subject subject in subjects) {
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
      Subject obj = Subject(entry['name'] as String, Color(entry['color'] as int));
      String topicsStr = entry['topics'] as String;
      if (topicsStr.isNotEmpty) {
        List<String> topics = topicsStr.split('[]');
        for (String topic in topics) {
          obj.topics.add(Topic.fromString(topic));
        }
      }
      res.add(obj);
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
