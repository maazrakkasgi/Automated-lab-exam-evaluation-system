import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Python Script Executor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PythonScriptExecutor(),
    );
  }
}

class PythonScriptExecutor extends StatefulWidget {
  const PythonScriptExecutor({super.key});

  @override
  _PythonScriptExecutorState createState() => _PythonScriptExecutorState();
}

class _PythonScriptExecutorState extends State<PythonScriptExecutor> {
  final TextEditingController _controller = TextEditingController();
  String _output = '';
  bool _isExecuting = false;

  Future<void> executePythonScript(String input) async {
    setState(() {
      _isExecuting = true;
      _output = '';
    });

    // Path to the Python script

    const pythonScriptPath = 'lib\\cat.py';

    // Start the Python script process

    final process = await Process.start('python', [pythonScriptPath]);

    // Send input to the Python script

    process.stdin.writeln(input);
    await process.stdin.flush();
    process.stdin.close();

    // Get the broadcast stream for stdout and stderr

    Stream<String> stdoutBroadcast = process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .asBroadcastStream();
    Stream<String> stderrBroadcast = process.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .asBroadcastStream();

    // Listen for outputs from the Python script

    stdoutBroadcast.listen((data) {
      setState(() {
        _output += '$data\n';
      });
    });

    // Listen for errors from the Python script

    stderrBroadcast.listen((data) {
      setState(() {
        _output += 'Python script error: $data\n';
      });
    });

    // Wait for the Python script to finish and then close the process

    await Future.wait([stdoutBroadcast.isEmpty, stderrBroadcast.isEmpty]);
    final exitCode = await process.exitCode;
    print('Python script exited with code: $exitCode');

    setState(() {
      _isExecuting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Python Script Executor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter Input for Python Script',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isExecuting
                  ? null
                  : () {
                      executePythonScript(_controller.text);
                    },
              child:
                  Text(_isExecuting ? 'Executing...' : 'Execute Python Script'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Output:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Text(_output),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
