// ignore: unused_import
import 'dart:developer' as developer;

import "package:flutter/material.dart";
import "package:studyappcs/states/topic.dart";

class Subject {
  String name = 'Default';
  List<Topic> topics = [];
  Color color = Colors.blue;
  List<int> testScores = [];

  Subject(this.name, this.color);

  Topic addTopic(Topic topic) {
    topics.add(topic);
    return topic;
  }

  String get asArea => name;

  void addScore(int score) {
    testScores.add(score);
  }

  String scoresToString() => testScores.join(',');

  Map<String, Object?> toMap() => {'name': name, 'color': color.value, 'scores': scoresToString()};
}
