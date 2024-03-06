import "package:flutter_application_1/subject.dart";
import 'package:flutter_application_1/task.dart';
import 'package:flutter_application_1/topic.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

class DataManager {
  static void saveSubjects(List<Subject> subjects) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> subjectNames = [];
    for (Subject subject in subjects) {
      developer.log(subject.name);
      subjectNames.add(subject.name);
      List<String> topicNames = [];
      for (Topic topic in subject.topics) {
        topicNames.add(topic.name);
      }
      prefs.setStringList('${subject.name}_topics', topicNames);
    }
    developer.log(subjectNames.toString());
    prefs.setStringList('subject_names', subjectNames);
  }

  static void addTopic(Subject subject, Topic topic) async {
    final prefs = await SharedPreferences.getInstance();
    String name = '${subject.name}_topics';
    List<String>? topics = prefs.getStringList(name) ?? [];
    topics.add(topic.name);
    prefs.setStringList(name, topics);
  }

  static void addSubject(String subject) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> names = prefs.getStringList('subject_names') ?? [];
    names.add(subject);
    prefs.setStringList('subject_names', names);
  }

  static void saveTasks(List<Task> tasks) async {
    List<String> taskInfos = [];
    final prefs = await SharedPreferences.getInstance();
    for (Task task in tasks) {
      String data = '${task.task}, ';
      data += '${task.type.toString()}, ';
      data += task.dueDate.millisecondsSinceEpoch.toString();
      taskInfos.add(data);
    }
    prefs.setStringList('tasks_info', taskInfos);
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
      tasks.add(Task(type, name, date));
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
        List<String>? topicNames = prefs.getStringList('${subjectName}_topics');
        if (topicNames != null) {
          for (String topicName in topicNames) {
            subject.addTopic(Topic(topicName));
          }
        }
        subjects.add(subject);
      }
    }
    return subjects;
  }
}
