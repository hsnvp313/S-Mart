import 'package:flutter/material.dart';
import 'pf.dart';

void main() {
  runApp(MyHome());
}

class MyHome extends StatelessWidget {
  const MyHome({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        child: Center(
          child: ProfilePicture(),
        ),
      ),
    );
  }
}
