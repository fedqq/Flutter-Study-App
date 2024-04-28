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
  String toString() {
    String ret = '${name}__${color.value}///';
    if (topics.isEmpty) {
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
    [name, color] = nameStr.split('__');
    if (topicsStr.isEmpty) return Subject(name, Color(int.parse(color)));
    List<String> topicsData = topicsStr.split(']');
    List<Topic> topics = List.generate(topicsData.length - 1, (i) => Topic.fromString(topicsData[i]));
    Subject ret = Subject(name, Color(int.parse(color)));
    ret.topics = topics;
    return ret;
  }
}
