import 'package:flutter/material.dart';

import '../account/account_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _onMicPressed() {
    // TODO: wire up transcribing
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ListenThenTask"),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
            child: AccountWidget(),
          ),
        ],
      ),

      body: const Center(child: Text("Tap the mic to add a task")),

      floatingActionButton: FloatingActionButton(
        onPressed: _onMicPressed,
        child: const Icon(Icons.mic),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
