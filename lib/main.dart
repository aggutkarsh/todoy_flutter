import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:todoey_flutter/screens/tasks.dart';
import 'package:provider/provider.dart';
import 'package:todoey_flutter/models/taskData.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:todoey_flutter/utilities/notificationHelper.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
NotificationAppLaunchDetails notificationAppLaunchDetails;

final FirebaseAuth _auth = FirebaseAuth.instance;

Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  await initNotifications(flutterLocalNotificationsPlugin);

  await Firebase.initializeApp();

  try {
    await _auth.signInAnonymously();
  } catch (e) {
    debugPrint('Firebase anonymous sign-in failed');
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => new TaskData(),
      child: MaterialApp(
        home: TasksScreen(),
      ),
    ),
  );
}
