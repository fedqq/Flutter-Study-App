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

  Map<String, Object?> toMap() {
    return {
      'name': name,
      'date': dueDate.millisecondsSinceEpoch.toString(),
      'completed': completed ? 1 : 0,
      'color': color.value,
      'desc': desc
    };
  }
}
