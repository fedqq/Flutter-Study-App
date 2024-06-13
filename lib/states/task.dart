import 'package:flutter/material.dart';

enum TaskType { homework, test, quiz, coursework, personal }

class Task {
  late String name;
  late DateTime dueDate;
  late bool completed;
  late Color color;
  late String desc;
  late int review;

  Task(this.name, this.dueDate, this.completed, this.color, this.desc);

  @override
  String toString() =>
      '$name;${dueDate.millisecondsSinceEpoch.toString()};${completed.toString()};${color.value};$desc';

  Map<String, Object?> toMap() {
    return {
      'name': name,
      'date': dueDate.millisecondsSinceEpoch.toString(),
      'completed': completed ? 1 : 0,
      'color': color.value,
      'desc': desc
    };
  }

  static Task fromString(String str) {
    List<String> data = str.split(';');
    String name = data[0];
    DateTime date = DateTime.fromMillisecondsSinceEpoch(int.parse(data[1]));
    bool completed = bool.parse(data[2]);
    Color color = Color(int.parse(data[3]));
    String desc = data[4];

    return Task(name, date, completed, color, desc);
  }
}
