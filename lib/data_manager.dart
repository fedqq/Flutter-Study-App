import "package:flutter_application_1/subject.dart";
import 'package:flutter_application_1/task.dart';
import 'package:flutter_application_1/topic.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

class DataManager {
  static void saveData(List<Subject> subjects) async {
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

  static void saveTasks(List<Task> tasks) {}

  static Future<SavedData> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    List<Subject> subjects = [];
    List<Topic> topics = [];

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
    return SavedData(subjects, topics);
  }
}

class SavedData {
  List<Subject> subjects = [];
  List<Topic> topics = [];

  SavedData(List<Subject> subjectsP, List<Topic> topicsP) {
    subjects = subjectsP;
    topics = topicsP;
  }
}
