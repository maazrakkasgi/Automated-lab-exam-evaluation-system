import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:highlight/languages/java.dart';
import 'package:highlight/languages/python.dart';
import 'package:highlight/languages/cpp.dart';

class CodeEditorPage extends StatelessWidget {
  final String studentName;
  final String studentUsn;
  final String code;
  final String language;
  final Map<String, dynamic> testCases;

  CodeEditorPage({
    required this.studentName,
    required this.studentUsn,
    required this.code,
    required this.language,
    required this.testCases,
  });

  @override
  Widget build(BuildContext context) {
    double grade = _calculateGrade();
    return Scaffold(
      appBar: AppBar(
        title: Text('Code Editor - $studentName'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Student: $studentName'),
            Text('USN: $studentUsn'),
            Text('Grade: ${grade.toStringAsFixed(2)} / 100'),
            const SizedBox(height: 10),
            Text('Language: $language'),
            const SizedBox(height: 10),
            Expanded(
              child: CodeEditor(
                code: code,
                language: language,
                testCases: testCases,
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateGrade() {
    if (testCases.isEmpty) {
      return 0.0;
    }

    int totalCases = testCases['total_cases'];
    int passedCases = totalCases - testCases['failed'] as int;
    return (passedCases / totalCases) * 100;
  }
}

class CodeEditor extends StatefulWidget {
  final String code;
  final String language;
  final Map<dynamic, dynamic> testCases;

  CodeEditor({
    required this.code,
    required this.language,
    required this.testCases,
  });

  @override
  _CodeEditorState createState() => _CodeEditorState();
}

class _CodeEditorState extends State<CodeEditor> {
  late CodeController controller;

  @override
  void initState() {
    super.initState();
    controller = CodeController(
      text: widget.code,
      language: _getLanguage(widget.language),
    );
  }

  dynamic _getLanguage(String language) {
    switch (language) {
      case 'python':
        return python;
      case 'java':
        return java;
      case 'c++':
        return cpp;
      default:
        return python;
    }
  }

  Widget _buildTestCaseResults() {
    if (widget.testCases.isEmpty) {
      return Container(
        child: const Text('No test case results to display.'),
      );
    }

    List<Widget> testCaseWidgets = [];
    widget.testCases['test_cases'].forEach((key, value) {
      print(value);
      testCaseWidgets.add(
        Card(
          child: ListTile(
            title: Text('Test Case $key'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Time Taken: ${value['time_taken']}'),
                Text('Expected Output: ${value['expected_output']}'),
                Text('Output: ${value['output']}'),
                Row(
                  children: [
                    Text('Success: '),
                    value['success']
                        ? Icon(Icons.check, color: Colors.green)
                        : Icon(Icons.close, color: Colors.red),
                  ],
                ),
                if (value['Error'] != null) Text('Error: ${value['Error']}'),
              ],
            ),
          ),
        ),
      );
    });

    return Expanded(
      child: ListView(
        children: testCaseWidgets,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: CodeTheme(
            data: CodeThemeData(styles: monokaiSublimeTheme),
            child: SingleChildScrollView(
              child: CodeField(
                controller: controller,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _buildTestCaseResults(),
      ],
    );
  }
}
