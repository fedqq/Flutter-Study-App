class Task {
  late String task;
  late TaskType type;
  late DateTime dueDate;
  late bool completed;

  Task(TaskType typeP, String taskP, DateTime dueDateP, bool completedP) {
    type = typeP;
    task = taskP;
    dueDate = dueDateP;
    completed = completedP;
  }

  @override
  String toString() => '$task,${type.toString()},${dueDate.millisecondsSinceEpoch.toString()},${completed.toString()}';

  static Task fromString(String str) {
    List<String> data = str.split(',');
    String name = data[0];
    TaskType type = typeFromString(data[1]);
    DateTime date = DateTime.fromMillisecondsSinceEpoch(int.parse(data[2]));
    bool completed = bool.parse(data[3]);
    return Task(type, name, date, completed);
  }
}

enum TaskType { homeWork, summativeTest, formativeTest, assignment, other, personal }

TaskType typeFromString(String str) => TaskType.values.firstWhere((element) => element.toString() == str);
