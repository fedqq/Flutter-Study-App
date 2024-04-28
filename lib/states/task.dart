import 'package:flutter/material.dart';

enum TaskType { homework, test, quiz, coursework, personal }

class Task {
  late String name;
  late TaskType type;
  late DateTime dueDate;
  late bool completed;
  late Color color;
  late String desc;
  late int review;

  Task(this.type, this.name, this.dueDate, this.completed, this.color, this.desc);

  @override
  String toString() =>
      '$name;${type.toString()};${dueDate.millisecondsSinceEpoch.toString()};${completed.toString()};${color.value};$desc';

  static Task fromString(String str) {
    List<String> data = str.split(';');
    String name = data[0];
    TaskType type = typeFromString(data[1]);
    DateTime date = DateTime.fromMillisecondsSinceEpoch(int.parse(data[2]));
    bool completed = bool.parse(data[3]);
    Color color = Color(int.parse(data[4]));
    String desc = data[5];
    return Task(type, name, date, completed, color, desc);
  }

  IconData getIcon() {
    switch (type) {
      case TaskType.homework:
        return Icons.home_work_rounded;
      case TaskType.test:
        return Icons.assignment_rounded;
      case TaskType.quiz:
        return Icons.home_work_rounded;
      case TaskType.coursework:
        return Icons.book_outlined;
      case TaskType.personal:
        return Icons.person_rounded;
    }
  }
}

TaskType typeFromString(String str) => TaskType.values.firstWhere((element) => element.toString() == str);
