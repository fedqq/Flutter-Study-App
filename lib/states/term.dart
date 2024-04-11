class Term {
  late String name;
  late String meaning;
  late bool learned;

  Term(String nameP, String meaningP, bool learnedP) {
    name = nameP;
    meaning = meaningP;
    learned = learnedP;
  }

  @override
  String toString() => '$name==$meaning==${learned.toString()}';

  static Term fromString(String str){
    var split = str.split('==');
    return  Term(split[0], split[1], bool.parse(split[2]));
  }
}
