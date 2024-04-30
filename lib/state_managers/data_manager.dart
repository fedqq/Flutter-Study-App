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

  static void saveData(List<Subject> subjects, List<Task> tasks, List<Task> completedTasks) async {
    clearAll();
    saveSubjects(subjects);
    saveTasks(tasks);
    saveCompletedTasks(completedTasks);
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

  static void saveCompletedTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> finalStrings = [];
    for (Task task in tasks) {
      finalStrings.add(task.toString());
    }
    prefs.setStringList('completed_tasks', finalStrings);
  }

  static Future<List<Subject>> loadSubjects() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> strs = prefs.getStringList('subjects') ?? [];
    List<Subject> subjects = [];
    for (String data in strs) {
      subjects.add(Subject.fromString(data));
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

  static Future<List<Task>> loadCompletedTasks() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> tasks = prefs.getStringList('completed_tasks') ?? [];
    List<Task> finalTasks = [];
    for (String task in tasks) {
      finalTasks.add(Task.fromString(task));
    }
    
    return finalTasks;
  }
}
