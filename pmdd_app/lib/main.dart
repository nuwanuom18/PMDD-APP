import 'package:flutter/material.dart';
import 'package:pmdd_app/test.dart';
import 'data.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TestApp(),
      //theme: ThemeData.dark(),
      theme: ThemeData(
          primaryColor: Colors.amber[500], primarySwatch: Colors.green),
      darkTheme: ThemeData.dark(),
    );
  }
}
