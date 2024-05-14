import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_console_widget/flutter_console.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FlutterConsoleController controller = FlutterConsoleController();

  dynamic process;

  Future<void> execFunction() async {
    const pythonScriptPath = 'lib\\cat.py';
    print("Called");

    // Start the Python script process
    process = await Process.start('python', [pythonScriptPath]);
    process.stdout.transform(utf8.decoder).listen((data) {
      print(data);
      controller.print(message: data, endline: true);
    });

    // Listen for errors from the Python script
    process.stderr.transform(utf8.decoder).listen((data) {
      print(data);
      controller.print(message: data, endline: true);
    });
  }

  void echoLoop() {
    controller.scan().then((value) {
      controller.print(message: value, endline: true);
      Uint8List data = Uint8List.fromList(value.codeUnits);
      process.stdin.add(data);
      print(data);
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
