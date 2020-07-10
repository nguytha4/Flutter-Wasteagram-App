import 'package:flutter/material.dart';
import 'wasteagram.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wasteagram',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: ListScreen(),
    );
  }
}