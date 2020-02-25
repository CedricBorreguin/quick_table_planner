import 'package:flutter/material.dart';
import 'package:quick_table_planner/screens/table_matrix_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color(0xFFCEA036),
      ),
      home: TablesMatrix(),
    );
  }
}
