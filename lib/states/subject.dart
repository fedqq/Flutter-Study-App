// ignore: unused_import
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:studyappcs/states/topic.dart';

class Subject {
  Subject(this.name, this.color, this.teacher, this.classroom);
  List<Topic> topics = <Topic>[];
  List<int> testScores = <int>[];
  Color color = Colors.blue;
  String teacher;
  String name = 'Default';
  String classroom;

  Topic addTopic(Topic topic) {
    topics.add(topic);
    return topic;
  }

  void addScore(int score) {
    testScores.add(score);
  }

  int _foldLearned(int num, Topic topic) => num + topic.cards.where((c) => c.learned).length;
  int _fold(int num, Topic topic) => num + topic.cards.length;

  int get learned => topics.fold(0, _foldLearned);
  int get total => topics.fold(0, _fold);

  double get percentage => total == 0 ? 0 : learned / total;
}
