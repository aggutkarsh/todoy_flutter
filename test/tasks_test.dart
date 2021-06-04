// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todoey_flutter/models/taskData.dart';

import 'package:todoey_flutter/screens/tasks.dart';
import 'mock.dart';

void main() {
  setupCloudFirestoreMocks();

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  });

  testWidgets('Task todo smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    Widget wrapWithController<T>(TaskData controller, Widget child) {
      return ChangeNotifierProvider(
          create: (_) => controller, child: MaterialApp(home: child));
    }

    await tester.pumpWidget(wrapWithController(
      TaskData(),
      TasksScreen(),
    ));

    // Verify that our counter starts at 0.
    expect(find.text('Todo List'), findsOneWidget);
    expect(find.text('1 task(s)'), findsOneWidget);
  });
}
