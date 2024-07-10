import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:studyappcs/utils/utils.dart';

enum TaskType { homework, test, quiz, coursework, personal }

class Task {
  Task(this.name, this.dueDate, this.color, this.desc, {required this.completed});
  late String name;
  late DateTime dueDate;
  late bool completed;
  late Color color;
  late String desc;
  late int review;

  bool compare(QueryDocumentSnapshot<StrMap> a) => a['name'] == name && a['date'] == dueDate.millisecondsSinceEpoch;
}
