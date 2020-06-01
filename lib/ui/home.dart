import 'package:flutter/material.dart';
import 'screen.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text("To Do"),
        backgroundColor: Colors.black54,
        centerTitle: true,
      ),
      body: new ToDoScreen(),
    );
  }
}
