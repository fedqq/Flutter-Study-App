// ignore_for_file: type_literal_in_constant_pattern, use_build_context_synchronously

import 'dart:convert';
// ignore: unused_import
import 'dart:developer' as developer;
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:studyapp/states/subject.dart";
import 'package:studyapp/states/task.dart';
import 'package:studyapp/utils/snackbar.dart';

class SaveDataManager {
  static void exportEverything() async {
    final Map prefsMap = await getEverythingMap();
    String encoded = const JsonEncoder.withIndent('   ').convert(prefsMap);
    String dir = (await getTemporaryDirectory()).path;
    String fileName = '$dir/study-app-backup-${DateTime.now().millisecondsSinceEpoch}.json';
    File temp = File(fileName);
    await temp.writeAsString(encoded);

    await Share.shareXFiles([XFile(fileName)]);
  }

  static void importEverything(void Function() loadCallback, BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    final Map backup = await getEverythingMap();
    clearAll();
    final String string = await File(result.files.single.path!).readAsString();
    final Map decoded = const JsonDecoder().convert(string);
    mapToPrefs(decoded);
    try {
      loadCallback();
    } catch (e) {
      simpleSnackBar(
        context,
        'Wrong format. Please use a file exported directly from the most updated version of this app',
      );
      mapToPrefs(backup);
    }
  }

  static void mapToPrefs(Map map) async {
    final prefs = await SharedPreferences.getInstance();
    for (String key in map.keys) {
      Object value = map[key];
      Type type = value.runtimeType;

      switch (type) {
        case int:
          prefs.setInt(key, value as int);
          break;
        case String:
          prefs.setString(key, value as String);
          break;
        case List:
          prefs.setStringList(key, (value as List).map((e) => e as String).toList());
          break;
        default:
          prefs.setBool(key, value as bool);
          break;
      }
    }
  }

  static Future<Map> getEverythingMap() async {
    final prefs = await SharedPreferences.getInstance();
    final Set<String> keys = prefs.getKeys();

    return {for (String key in keys) key: prefs.get(key)};
  }

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

    return finalTasks
        .where((element) => element.dueDate.difference(DateTime.now()) < const Duration(days: 30))
        .toList();
  }
}
