class Task {
  int sequence;
  String task;
  int scheduledTime;
  bool status;

  Task({this.status = false, this.task, this.sequence, this.scheduledTime});

  void toggleStatus() {
    status = !status;
  }
}
