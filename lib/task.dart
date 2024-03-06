class Task {
  late String task;
  late TaskType type;
  late DateTime dueDate;

  Task(TaskType typeP, String taskP, DateTime dueDateP) {
    type = typeP;
    task = taskP;
    dueDate = dueDateP;
  }
}

enum TaskType { homeWork, summativeTest, formativeTest, assignment, other, personal }

TaskType taskFromString(String str) => TaskType.values.firstWhere((element) => element.toString() == str);
