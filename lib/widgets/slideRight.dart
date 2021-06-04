import 'package:flutter/material.dart';
import 'package:todoey_flutter/utilities/constants.dart';

Widget slideRight({bool isRedo = false}) {
  return Container(
    color: !isRedo ? Colors.green : Colors.grey,
    child: Align(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 20,
          ),
          Icon(
            Icons.check,
            color: Colors.white,
          ),
          Text(
            !isRedo
                ? " $kTileSwipeLeftTitle_Done"
                : " $kTileSwipeLeftTitle_Redo",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
      alignment: Alignment.centerLeft,
    ),
  );
}
