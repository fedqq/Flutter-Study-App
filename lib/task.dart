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
}

enum TaskType { homeWork, summativeTest, formativeTest, assignment, other, personal }

TaskType taskFromString(String str) => TaskType.values.firstWhere((element) => element.toString() == str);
