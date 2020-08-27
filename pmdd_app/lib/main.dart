import 'package:flutter/material.dart';
import 'package:pmdd_app/test.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TestApp(),
      theme: ThemeData(
          primaryColor: Colors.amber, primarySwatch: Colors.deepOrange),
    );
  }
}
