import 'package:flutter/material.dart';

class MessageScreen extends StatefulWidget {
  final String? id;

  const MessageScreen({super.key, this.id});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Message Screen"),
      ),
      body:  Center(child: Text("Message Screen ${widget.id}")),
    );
  }
}
