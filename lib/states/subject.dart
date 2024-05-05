import "package:flutter/material.dart";
import "package:flutter_application_1/states/topic.dart";

// ignore: unused_import
import 'dart:developer' as developer;

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
    String scores = '';
    for (int score in testScores) {
      scores += '$score||';
    }
    if (scores.isNotEmpty) scores = scores.substring(0, scores.length - 2);

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
}
