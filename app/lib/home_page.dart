import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_console_widget/flutter_console.dart';

class HomePage extends StatelessWidget {
  HomePage({
    super.key,
  });

  final FlutterConsoleController controller = FlutterConsoleController();
  dynamic process;
  void execFunction() async {
    const pythonScriptPath = 'lib\\cat.py';

    // Start the Python script process
    process = await Process.start('python', [pythonScriptPath]);
    process.stdout.transform(utf8.decoder).listen((data) {
      print('Python script says: $data');
    });

    // Listen for errors from the Python script
    process.stderr.transform(utf8.decoder).listen((data) {
      print('Python script error: $data');
    });
  }

  void echoLoop() {
    controller.scan().then((value) {
      controller.print(message: value, endline: true);
      process.stdin.add(value);
      controller.focusNode.requestFocus();
      echoLoop();
    });
  }

  @override
  Widget build(BuildContext context) {
    echoLoop();
    execFunction();
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example'),
      ),
      body: FlutterConsole(
        controller: controller,
        height: size.height,
        width: size.width,
      ),
    );
  }
}
