import "package:flutter/material.dart";
import "package:flutter_application_1/states/topic.dart";

class Subject {
  String name = 'Default';
  List<Topic> topics = [];
  Color color = Colors.blue;

  Subject(this.name, this.color);

  void addTopic(Topic topic) {
    topics.add(topic);
  }

  @override
  String toString() => '$name--${color.value}';
}
