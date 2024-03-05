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
}
