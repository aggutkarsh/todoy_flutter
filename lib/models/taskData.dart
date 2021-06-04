import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:todoey_flutter/models/task.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:collection';

import 'package:todoey_flutter/utilities/constants.dart';

final _firestore = FirebaseFirestore.instance;

class TaskData extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  User _currentUser;

  List<Task> _tasks = [];
  bool _isLoading = false;

  TaskData() {
    _currentUser = _auth.currentUser;
    getUserTasks();
  }

  get isLoading => _isLoading;

  set isLoading(bool loadingStatus) {
    _isLoading = loadingStatus;
    notifyListeners();
  }

  Future fetchUserTasks(bool status, bool isOrderByDesc) async {
    return await _firestore
        .collection(kFireStoreCollection)
        .where(kField_UserId, isEqualTo: _currentUser.uid)
        .where(kField_Status, isEqualTo: status)
        .orderBy(kField_Sequence, descending: isOrderByDesc)
        .get();
  }

  void getUserTasks() async {
    _tasks.clear();
    isLoading = true;

    if (_currentUser != null) {
      var queryActiveTasks = await fetchUserTasks(false, true);
      queryActiveTasks.docs.forEach((result) {
        _tasks.add(
          Task(
              task: result.data()[kField_Task],
              status: result.data()[kField_Status],
              sequence: result.data()[kField_Sequence],
              scheduledTime: result.data()[kField_ScheduledTime]),
        );
      });
      var queryCompletedTasks = await fetchUserTasks(true, true);
      queryCompletedTasks.docs.forEach((result) {
        _tasks.add(
          Task(
              task: result.data()[kField_Task],
              status: result.data()[kField_Status],
              sequence: result.data()[kField_Sequence],
              scheduledTime: result.data()[kField_ScheduledTime]),
        );
      });
    }
    if (_tasks.length == 0) {
      _tasks.add(Task(task: kDefaultTaskTitle, sequence: 1));
    }

    isLoading = false;
    notifyListeners();
  }

  int get taskCount {
    return _tasks.length;
  }

  UnmodifiableListView get taskList {
    return UnmodifiableListView(_tasks);
  }

  Future<QuerySnapshot> queryUserTasks(int sequence) async {
    return await _firestore
        .collection(kFireStoreCollection)
        .where(kField_UserId, isEqualTo: _currentUser.uid)
        .where(kField_Sequence, isEqualTo: sequence)
        .get();
  }

  void addTask(Task newTask) {
    _tasks.insert(0, newTask);
    notifyListeners();
  }

  void renameTaskAt(
      {String newTask, Task task, bool isLocalUpdate = false}) async {
    if (!isLocalUpdate) {
      isLoading = true;
      var a = await queryUserTasks(task.sequence);
      if (a.docs.length > 0) {
        await _firestore
            .collection(kFireStoreCollection)
            .doc(a.docs[0].id)
            .update({kField_Task: newTask});
      } else {
        await _firestore.collection(kFireStoreCollection).doc().set({
          kField_UserId: _currentUser.uid,
          kField_Task: newTask,
          kField_Sequence: task.sequence,
          kField_Status: task.status,
          kField_ScheduledTime: task.scheduledTime
        });
      }

      getUserTasks();
    } else {
      _tasks[0].task = newTask;
      notifyListeners();
    }
  }

  void updateTaskSchedule(int schedule, Task taskItem) async {
    isLoading = true;
    var a = await queryUserTasks(taskItem.sequence);
    if (a.docs.length > 0) {
      await _firestore
          .collection(kFireStoreCollection)
          .doc(a.docs[0].id)
          .update({kField_ScheduledTime: schedule});
    }

    getUserTasks();
  }

  void updateTask(Task taskItem) async {
    isLoading = true;
    var a = await queryUserTasks(taskItem.sequence);
    if (a.docs.length > 0) {
      await _firestore
          .collection(kFireStoreCollection)
          .doc(a.docs[0].id)
          .update({kField_Status: !taskItem.status});
    }

    getUserTasks();
  }

  void reOrderTasks(Task task1, Task task2) async {
    isLoading = true;
    var a = await queryUserTasks(task2.sequence);
    if (a.docs.length > 0) {
      await _firestore
          .collection(kFireStoreCollection)
          .doc(a.docs[0].id)
          .delete()
          .then((_) async {
        var a = await queryUserTasks(task1.sequence);
        if (a.docs.length > 0) {
          await _firestore
              .collection(kFireStoreCollection)
              .doc(a.docs[0].id)
              .update({kField_Sequence: task2.sequence}).then((_) async {
            await _firestore.collection(kFireStoreCollection).add({
              kField_UserId: _currentUser.uid,
              kField_Task: task2.task,
              kField_Status: task2.status,
              kField_Sequence: task1.sequence,
              kField_ScheduledTime: task2.scheduledTime
            });
          });
        }
      });
    }

    getUserTasks();
  }

  void deleteTask({Task taskItem}) async {
    isLoading = true;
    var a = await queryUserTasks(taskItem.sequence);
    if (a.docs.length > 0) {
      await _firestore
          .collection(kFireStoreCollection)
          .doc(a.docs[0].id)
          .delete();
    }

    getUserTasks();
  }
}
