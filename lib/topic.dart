import "package:flutter_application_1/term.dart";

class Topic {
  String name = '';
  List<Term> terms = [];

  Topic(String nameP) {
    name = nameP;
  }

  void addTerm(term) {
    terms.add(term);
  }

  @override
  String toString() {
    String ret = '$name|';

    String termData = '';
    for (Term term in terms) {
      termData += '${term.toString()},';
    }

    termData = termData.substring(0, termData.length - 1);

    ret = '$name|$termData';
    return ret;
  }

  static Topic fromString(String str) {
    List<String> split = str.split("|");

    String name = split[0];
    Topic finalTopic = Topic(name);
    String terms = split[1];
    if (terms != '') {
      List<String> terms = split[1].split(',');
      for (String termString in terms) {
        finalTopic.addTerm(Term.fromString(termString));
      }
    }

    return finalTopic;
  }
}
