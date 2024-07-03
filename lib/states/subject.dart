// ignore: unused_import
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:studyappcs/states/flashcard.dart';
import 'package:studyappcs/states/topic.dart';

class Subject {

  Subject(this.name, this.color, this.teacher, this.classroom);
  String name = 'Default';
  List<Topic> topics = <Topic>[];
  Color color = Colors.blue;
  List<int> testScores = <int>[];
  String teacher;
  String classroom;

  Topic addTopic(Topic topic) {
    topics.add(topic);
    return topic;
  }

  String get asArea => name;

  void addScore(int score) {
    testScores.add(score);
  }

  int get learned => topics.fold(0, (int a, Topic b) => a + b.cards.where((FlashCard c) => c.learned).length);

  int get total => topics.fold(0, (int a, Topic b) => a + b.cards.length);

  double get percentage => total == 0 ? 0 : learned / total;
}
