import 'package:flutter/material.dart';
import "package:flutter_application_1/subject.dart";
import 'package:flutter_application_1/task.dart';
import 'package:flutter_application_1/term.dart';
import 'package:flutter_application_1/topic.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: unused_import
import 'dart:developer' as developer;

class ReturnData {
  late List<Subject> subjects;
  late List<Task> tasks;

  ReturnData(subjectsP, tasksP) {
    subjects = subjectsP;
    tasks = tasksP;
  }
}

class SaveDataManager {
  static void clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  static void saveData(List<Subject> subjects, List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    saveSubjects(subjects);
    saveTasks(tasks);
  }

  static void saveSubjects(List<Subject> subjects) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> subjectNames = [];

    for (Subject subject in subjects) {
      subjectNames.add('${subject.name}--${subject.color.value}');
      List<String> topicStrings = [];
      for (Topic topic in subject.topics) {
        String topicString = '';
        topicString += topic.name;
        topicString += '|';
        String termsString = '';
        for (Term term in topic.terms) {
          termsString += '${term.name}==${term.meaning}==${term.learned.toString()}';
          termsString += ',';
        }
        termsString = termsString.substring(0, termsString.length - 1);
        topicString += termsString;
        topicStrings.add(topicString);
      }
      prefs.setStringList('${subject.name}||topics', topicStrings);
    }
    prefs.setStringList('subjectss', subjectNames);
  }

  static Future<ReturnData> loadData() async => ReturnData(await loadSubjects(), await loadTasks());

  static void saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> finalStrings = [];
    for (Task task in tasks) {
      String taskString = '';
      taskString += task.task;
      taskString += ',';
      taskString += task.type.toString();
      taskString += ',';
      taskString += task.dueDate.millisecondsSinceEpoch.toString();
      taskString += ',';
      taskString += task.completed.toString();
      finalStrings.add(taskString);
    }
    prefs.setStringList('taskss', finalStrings);
  }

  static Future<List<Subject>> loadSubjects() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> names = prefs.getStringList('subjectss') ?? [];
    List<Subject> subjects = [];
    for (String subjectData in names) {
      var split = subjectData.split('--');
      String name = split[0];
      Color color = Color(int.parse(split[1]));
      List<String> topics = prefs.getStringList('$name||topics') ?? [];
      Subject subject = Subject(name, colour: color);
      for (String topic in topics) {
        List<String> split = topic.split("|");
        String name = split[0];
        List<Term> termObjs = [];
        try {
          List<String> terms = split[1].split(',');
          for (String termString in terms) {
            var splitString = termString.split('==');
            termObjs.add(Term(splitString[0], splitString[1], bool.parse(splitString[2])));
          }
        } catch (e) {
          termObjs = [];
        }
        Topic finalTopic = Topic(name);
        finalTopic.terms = termObjs;
        subject.addTopic(finalTopic);
      }
      subjects.add(subject);
    }

    return subjects;
  }

  static Future<List<Task>> loadTasks() async {
    return [
      Task(
        TaskType.assignment,
        'asdf',
        DateTime.now(),
        false,
      )
    ];
  }
}
