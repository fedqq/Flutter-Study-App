import 'package:flutter/material.dart';

enum TaskType { homework, test, quiz, coursework, personal }

class Task {

  Task(this.name, this.dueDate, this.color, this.desc, {required this.completed});
  late String name;
  late DateTime dueDate;
  late bool completed;
  late Color color;
  late String desc;
  late int review;
}
