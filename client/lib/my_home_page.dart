import 'package:client/code_editor.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.userName, required this.serverIp});
  final String userName;
  final String serverIp;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Client'),
      ),
      body: CodeEditor(
        username: widget.userName,
        serverIp: widget.serverIp,
      ),
    );
  }
}
