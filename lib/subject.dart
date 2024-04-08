import "package:flutter/material.dart";
import "package:flutter_application_1/topic.dart";

class Subject {
  String name = 'Default';
  List<Topic> topics = [];
  Color color = Colors.blue;
  IconData icon = Icons.abc;

  Subject(String nameP, {Color colour = Colors.blue, IconData icon = Icons.abc}) {
    icon = icon;
    color = colour;
    name = nameP;
  }

  void addTopic(Topic topic) {
    topics.add(topic);
  }

  @override
  String toString() => '$name--${color.value}';
}
