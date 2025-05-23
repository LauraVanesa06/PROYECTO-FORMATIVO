import 'package:flutter/material.dart';

class FailureView extends StatelessWidget {
  const FailureView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Column(children: [Text('Fallo'), Text('Internet')])),
    );
  }
}