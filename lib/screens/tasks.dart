import 'package:flutter/material.dart';
import 'package:todoey_flutter/models/taskData.dart';
import 'package:todoey_flutter/widgets/taskList.dart';
import 'package:provider/provider.dart';

class TasksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<TaskData>(context).isLoading;

    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(
                top: 60.0, left: 30.0, right: 30.0, bottom: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Todo List',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Source-Sans',
                      fontWeight: FontWeight.w700,
                      fontSize: 50.0),
                ),
                Text(
                  isLoading
                      ? '0 task'
                      : '${Provider.of<TaskData>(context).taskCount} task(s)',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Source-Sans',
                    fontSize: 18.0,
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
              ),
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation(Colors.lightBlueAccent[100]),
                      ),
                    )
                  : TaskList(),
            ),
          )
        ],
      ),
    );
  }
}
