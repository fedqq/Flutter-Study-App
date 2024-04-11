import 'package:flutter/material.dart';
import "package:flutter_application_1/states/subject.dart";
import 'package:flutter_application_1/states/task.dart';
import 'package:flutter_application_1/states/topic.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: unused_import
import 'dart:developer' as developer;

class SaveDataManager {
  static void clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  static void saveData(List<Subject> subjects, List<Task> tasks) async {
    clearAll();
    saveSubjects(subjects);
    saveTasks(tasks);
  }

  static void saveSubjects(List<Subject> subjects) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> subjectData = [];

    for (Subject subject in subjects) {
      subjectData.add(subject.toString());

      List<String> topicData = [];

      for (Topic topic in subject.topics) {
        topicData.add(topic.toString());
      }
      prefs.setStringList('${subject.name}||topics', topicData);
    }
    prefs.setStringList('subjects', subjectData);
  }

  static void saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> finalStrings = [];
    for (Task task in tasks) {
      finalStrings.add(task.toString());
    }
    prefs.setStringList('tasks', finalStrings);
  }

  static Future<List<Subject>> loadSubjects() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> names = prefs.getStringList('subjects') ?? [];
    List<Subject> subjects = [];
    for (String subjectData in names) {
      var split = subjectData.split('--');
      String name = split[0];
      Color color = Color(int.parse(split[1]));
      List<String> topics = prefs.getStringList('$name||topics') ?? [];
      Subject subject = Subject(name, colour: color);
      for (String topic in topics) {
        subject.addTopic(Topic.fromString(topic));
      }
      subjects.add(subject);
    }

    return subjects;
  }

  static Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> tasks = prefs.getStringList('tasks') ?? [];
    List<Task> finalTasks = [];
    for (String task in tasks) {
      finalTasks.add(Task.fromString(task));
    }
    return finalTasks;
  }
}
