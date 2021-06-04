import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:todoey_flutter/models/scrollEventNotifier.dart';
import 'package:todoey_flutter/models/task.dart';
import 'package:todoey_flutter/models/taskData.dart';
import 'package:todoey_flutter/utilities/constants.dart';
import 'package:todoey_flutter/utilities/timeZone.dart' as tz;
import 'package:todoey_flutter/widgets/slideLeft.dart';
import 'package:todoey_flutter/widgets/slideRight.dart';
import 'package:todoey_flutter/widgets/taskItem.dart';
import 'package:provider/provider.dart';
import 'package:todoey_flutter/utilities/notificationHelper.dart';

import '../main.dart';

class TaskList extends StatefulWidget {
  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  bool isScrolledToTop = false;
  ScrollController _controller;

  _scrollListener() {
    if (_controller.offset <= _controller.position.minScrollExtent &&
        !_controller.position.outOfRange &&
        _controller.position.userScrollDirection == ScrollDirection.forward) {
      setState(() {
        isScrolledToTop = !isScrolledToTop;
      });
    }
  }

  void scheduleAgain(Task taskItem) async {
    final timeZone = tz.TimeZone();
    final scheduledDate = await timeZone.getTZDateTime(
        DateTime.fromMillisecondsSinceEpoch(taskItem.scheduledTime));

    final currentTZTime = await timeZone.getCurrentTZDateTime();

    if (scheduledDate.isAfter(currentTZTime)) {
      scheduleNotification(flutterLocalNotificationsPlugin,
          taskItem.sequence.toString(), taskItem.task, scheduledDate);
    }
  }

  @override
  void initState() {
    _controller = ScrollController();
    _controller.addListener(_scrollListener);

    super.initState();
  }

  @override
  void dispose() {
    _controller.removeListener(_scrollListener);
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskData>(builder: (context, taskData, child) {
      return ChangeNotifierProvider(
        create: (_) => new ScrollEventNotifier(false),
        child: Builder(builder: (context) {
          var scrollListner = Provider.of<ScrollEventNotifier>(context);
          return NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification is ScrollStartNotification) {
                scrollListner.isScrolling = true;
                taskData.addTask(Task(
                    task: kOnPullTaskTitle,
                    sequence: taskData.taskList[0].sequence + 1));
              } else if (scrollNotification is ScrollEndNotification) {
                scrollListner.isScrolling = false;
                if (isScrolledToTop) {
                  setState(() {
                    isScrolledToTop = !isScrolledToTop;
                  });
                  taskData.renameTaskAt(
                      newTask: kOnReleaseTaskTitle,
                      task: taskData.taskList[0],
                      isLocalUpdate: true);
                } else {
                  taskData.deleteTask(taskItem: taskData.taskList[0]);
                }
              }
              return true;
            },
            child: ReorderableListView(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              scrollController: _controller,
              physics: BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              onReorder: (int oldIndex, int newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final Task itemToReplace = taskData.taskList[oldIndex];
                  final Task itemReplacedWith = taskData.taskList[newIndex];

                  taskData.reOrderTasks(itemToReplace, itemReplacedWith);
                });
              },
              children: List.generate(
                taskData.taskCount,
                (index) {
                  final taskItem = taskData.taskList[index];
                  return Dismissible(
                    key: Key('${taskItem.task}_$index'),
                    dismissThresholds: {
                      DismissDirection.startToEnd: 0.5,
                      DismissDirection.endToStart: 0.5,
                    },
                    background: slideRight(isRedo: taskItem.status),
                    secondaryBackground: slideLeft(),
                    confirmDismiss: (direction) {
                      if (direction == DismissDirection.endToStart) {
                        taskData.deleteTask(taskItem: taskItem);
                      } else if (direction == DismissDirection.startToEnd) {
                        taskData.updateTask(taskItem);

                        if (taskItem.scheduledTime != null) {
                          if (!taskItem.status) {
                            turnOffNotificationById(
                                flutterLocalNotificationsPlugin,
                                taskItem.sequence);
                          } else {
                            scheduleAgain(taskItem);
                          }
                        }
                      }
                      return;
                    },
                    child: TaskItem(
                      task: taskItem,
                      updateTaskCallback: (newTask) {
                        taskData.renameTaskAt(
                            newTask: newTask, task: taskData.taskList[index]);
                      },
                      deleteTaskCallback: (task) {
                        if (task.task == kOnReleaseTaskTitle) {
                          taskData.deleteTask(taskItem: task);
                        }
                      },
                      scheduleTaskCallback: (dateTime) {
                        taskData.updateTaskSchedule(
                            dateTime.millisecondsSinceEpoch,
                            taskData.taskList[index]);
                        scheduleNotification(
                            flutterLocalNotificationsPlugin,
                            taskData.taskList[index].sequence.toString(),
                            taskData.taskList[index].task,
                            dateTime);
                      },
                    ),
                  );
                },
              ),
            ),
          );
        }),
      );
    });
  }
}
