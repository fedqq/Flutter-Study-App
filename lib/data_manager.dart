import 'package:flutter/material.dart';
import "package:flutter_application_1/subject.dart";
import 'package:flutter_application_1/task.dart';
import 'package:flutter_application_1/topic.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataManager {
  static void clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  static void saveSubjects(List<Subject> subjects) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> subjectNames = [];
    for (Subject subject in subjects) {
      subjectNames.add(subject.name);
      List<String> topicNames = [];
      for (Topic topic in subject.topics) {
        topicNames.add(topic.name);
      }
      topicNames.add(subject.icon.codePoint.toString());
      prefs.setStringList('${subject.name}_topics', topicNames);
    }
    prefs.setStringList('subject_names', subjectNames);
  }

  static void addTopic(Subject subject, Topic topic) async {
    final prefs = await SharedPreferences.getInstance();
    String name = '${subject.name}_topics';
    List<String>? topics = prefs.getStringList(name) ?? [];
    try {
      String icon = topics.removeLast();
    } catch (e) {
      String icon = Icons.add.codePoint.toString();
    }
    topics.add(topic.name);
    prefs.setStringList(name, topics);
  }

  static void addSubject(String subject) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> names = prefs.getStringList('subject_names') ?? [];
    names.add(subject);
    prefs.setStringList('subject_names', names);
  }

  static void saveTasks(List<Task> tasks, {bool archive = false}) async {
    List<String> taskInfos = [];
    final prefs = await SharedPreferences.getInstance();
    for (Task task in tasks) {
      String data = '${task.task}, ';
      data += '${task.type.toString()}, ';
      data += task.dueDate.millisecondsSinceEpoch.toString();
      data += task.completed.toString();
      taskInfos.add(data);
    }
    if (archive) {
      prefs.setStringList('tasks_info', taskInfos);
    } else {
      prefs.setStringList('archive_tasks_info', taskInfos);
    }
  }

  static void clearTasks() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('tasks_info', []);
  }

  static void clearSubject() async {
    final prefs = await SharedPreferences.getInstance();
    for (String name in prefs.getStringList('subject_names') ?? []) {
      prefs.setStringList('${name}_topics', []);
    }
    prefs.setStringList('subject_names', []);
  }

  static Future<List<Task>> loadTasks() async {
    List<Task> tasks = [];
    final prefs = await SharedPreferences.getInstance();
    List<String> taskNames = prefs.getStringList('tasks_info') ?? [];
    for (String task in taskNames) {
      List<String> split = task.split(', ');
      String name = split[0];
      TaskType type = taskFromString(split[1]);
      DateTime date = DateTime.fromMillisecondsSinceEpoch(int.parse(split[2]));
      bool completed = (split[3] == 'true');
      tasks.add(Task(type, name, date, completed));
    }
    return tasks;
  }

  static Future<List<Task>> loadTasksArchive() async {
    List<Task> tasks = [];
    final prefs = await SharedPreferences.getInstance();
    List<String> taskNames = prefs.getStringList('archive_tasks_info') ?? [];
    for (String task in taskNames) {
      List<String> split = task.split(', ');
      String name = split[0];
      TaskType type = taskFromString(split[1]);
      DateTime date = DateTime.fromMillisecondsSinceEpoch(int.parse(split[2]));
      bool completed = (split[3] == 'true');
      tasks.add(Task(type, name, date, completed));
    }
    return tasks;
  }

  static Future<List<Subject>> loadSubjects() async {
    final prefs = await SharedPreferences.getInstance();
    List<Subject> subjects = [];

    List<String>? subjectNames = prefs.getStringList('subject_names');
    if (subjectNames != null) {
      for (String subjectName in subjectNames) {
        Subject subject = Subject(subjectName);
        List<String>? subjectData = prefs.getStringList('${subjectName}_topics');
        if (subjectData != null) {
          String icon = subjectData.removeLast();
          for (String topicName in subjectData) {
            subject.addTopic(Topic(topicName));
          }
          subject.icon = IconData(int.parse(icon));
        }
        subjects.add(subject);
      }
    }
    return subjects;
  }
}
