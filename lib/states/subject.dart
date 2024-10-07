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

  String get asArea => name;

  void addScore(int score) {
    testScores.add(score);
  }

  //Sums the amoutn of learned cards from each topic using a fold
  int _foldLearned(int num, Topic topic) => num + topic.cards.where((c) => c.learned).length;

  //Sums the amount of cards in each topic. 
  int _fold(int num, Topic topic) => num + topic.cards.length;

  int get learned => topics.fold(0, _foldLearned);

  int get total => topics.fold(0, _fold);

  double get percentage => total == 0 ? 0 : learned / total;
}
