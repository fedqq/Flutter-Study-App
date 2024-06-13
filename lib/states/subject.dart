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

  void addTopic(Topic topic) {
    topics.add(topic);
  }

  String get asArea => name;

  void addScore(int score) {
    testScores.add(score);
  }

  @override
  String toString() {
    final scores = scoresToString();

    String ret = '${name}__${color.value}__$scores///';
    if (topics.isNotEmpty) {
      for (Topic topic in topics) {
        ret += '${topic.toString()}]';
      }
    }

    return ret;
  }

  static Subject fromString(String str) {
    String nameStr;
    String topicsStr;
    [nameStr, topicsStr] = str.split('///');
    String name;
    String color;
    String scores;
    [name, color, scores] = nameStr.split('__');

    if (topicsStr.isEmpty) return Subject(name, Color(int.parse(color)));
    List<String> topicsData = topicsStr.split(']');
    List<Topic> topics = List.generate(topicsData.length - 1, (i) => Topic.fromString(topicsData[i]));
    Subject ret = Subject(name, Color(int.parse(color)));
    ret.topics = topics;

    List<String> splitScores = scores.split('||');
    ret.testScores = List.generate(splitScores.length, (index) => int.parse(splitScores[index]));

    return ret;
  }

  String scoresToString() {
    String scores = '';
    for (int score in testScores) {
      scores += '$score||';
    }
    scores = scores.isNotEmpty ? scores.substring(0, scores.length - 2) : '0';
    return scores;
  }

  Map<String, Object?> toMap() {
    String t = '';
    bool flag = false;
    for (Topic topic in topics) {
      t += '${topic.toString()}[]';
      flag = true;
    }
    if (flag) t = t.substring(0, t.length - 2);

    return {'name': name, 'color': color.value, 'scores': scoresToString(), 'topics': topics.join('[]')};
  }
}
