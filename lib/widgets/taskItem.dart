import 'package:flutter/material.dart';
import 'package:todoey_flutter/models/scrollEventNotifier.dart';
import 'package:todoey_flutter/models/task.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todoey_flutter/utilities/constants.dart';

class TaskItem extends StatefulWidget {
  final Task task;
  final Function updateTaskCallback;
  final Function deleteTaskCallback;
  final Function scheduleTaskCallback;

  TaskItem(
      {this.task,
      this.updateTaskCallback,
      this.deleteTaskCallback,
      this.scheduleTaskCallback});

  @override
  _TaskItemState createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  TextEditingController textController;
  FocusNode myFocusNode;
  DateTime scheduleDate;
  TimeOfDay scheduleTime;

  @override
  void initState() {
    myFocusNode = FocusNode();
    scheduleDate = DateTime.now();
    scheduleTime = TimeOfDay.now();

    setState(() {
      textController = TextEditingController(text: widget.task.task);

      if (widget.task.task == kOnReleaseTaskTitle) {
        myFocusNode.requestFocus();
        textController.text = '';
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    textController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isScrolling = Provider.of<ScrollEventNotifier>(context).isScrolling;

    if (widget.task.scheduledTime != null) {
      scheduleDate =
          DateTime.fromMillisecondsSinceEpoch(widget.task.scheduledTime);
      scheduleTime = TimeOfDay.fromDateTime(scheduleDate);
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      child: GestureDetector(
        onDoubleTap: () async {
          final DateTime pickedDate = await showDatePicker(
              context: context,
              firstDate: DateTime(DateTime.now().year - 5),
              lastDate: DateTime(DateTime.now().year + 5),
              initialDate: scheduleDate);
          if (pickedDate != null) {
            final TimeOfDay pickedTime = await showTimePicker(
                context: context, initialTime: scheduleTime);
            if (pickedTime != null) {
              final selectedDateTime = DateTime(
                  pickedDate.year,
                  pickedDate.month,
                  pickedDate.day,
                  pickedTime.hour,
                  pickedTime.minute);
              widget.scheduleTaskCallback(selectedDateTime);
            }
          }
        },
        child: TweenAnimationBuilder(
          tween: Tween(
              begin: isScrolling ? 0 : -0.05, end: isScrolling ? -0.05 : 0),
          duration: Duration(milliseconds: 200),
          builder: (_, rotation, _child) {
            return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.1)
                ..rotateX(widget.task.task == kOnPullTaskTitle
                    ? rotation.toDouble()
                    : 0),
              alignment: Alignment.center,
              child: Container(
                decoration: BoxDecoration(
                    color: !widget.task.status
                        ? Colors.lightBlueAccent[100]
                        : Colors.grey[100],
                    border: Border.all(
                      color: !widget.task.status
                          ? Colors.lightBlueAccent[200]
                          : Colors.grey[200],
                    )),
                child: ListTile(
                  minVerticalPadding: 0.0,
                  visualDensity: VisualDensity.compact,
                  onTap: () {
                    myFocusNode.requestFocus();
                  },
                  title: TextField(
                    focusNode: myFocusNode,
                    controller: textController,
                    style: TextStyle(
                        color: widget.task.status ? Colors.black : Colors.white,
                        fontSize: 20.0,
                        fontFamily: 'Source-Sans',
                        decoration: widget.task.status
                            ? TextDecoration.lineThrough
                            : null),
                    decoration: InputDecoration(
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        widget.updateTaskCallback(value);
                      } else {
                        widget.deleteTaskCallback(widget.task);
                        textController.text = widget.task.task;
                      }
                    },
                  ),
                  subtitle: widget.task.scheduledTime != null
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Text(
                            DateFormat(kScheduleTimeFormat).format(
                                DateTime.fromMillisecondsSinceEpoch(
                                    widget.task.scheduledTime)),
                            style: TextStyle(
                                color: widget.task.status
                                    ? Colors.black
                                    : Colors.white,
                                decoration: widget.task.status
                                    ? TextDecoration.lineThrough
                                    : null,
                                fontFamily: 'Source-Sans',
                                fontSize: 12.0),
                          ),
                        )
                      : null,
                  trailing: Icon(
                      widget.task.scheduledTime == null
                          ? Icons.add_alarm
                          : widget.task.status
                              ? Icons.alarm_off
                              : Icons.alarm_on,
                      color: widget.task.status ? Colors.black : Colors.white),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
