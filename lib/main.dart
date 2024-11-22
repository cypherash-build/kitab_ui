import 'package:flutter/material.dart';

void main() {
  runApp(const KiTabApp());
}

class KiTabApp extends StatelessWidget {
  const KiTabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KiTab',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('KiTab'),
        ),
        body: Center(
          // Example: A Column with two Containers
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                height: 200,
                color: Colors.blue,
                child: const Center(
                    child: Text('Main Display Area',
                        style: TextStyle(color: Colors.white))),
              ),
              Container(
                height: 200,
                color: Colors.amber,
                child: const Center(
                    child: Text('Note Taking Area',
                        style: TextStyle(color: Colors.white))),
              )
            ],
          ),
        ),
      ),
    );
  }
}
