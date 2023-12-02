import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:highlight/languages/python.dart';

final controller = CodeController(
  text: '...', // Initial code
  language: python,
);

class CodeEditor extends StatefulWidget {
  const CodeEditor({super.key, required this.code});
  final String code;

  @override
  State<CodeEditor> createState() => _CodeEditorState();
}

class _CodeEditorState extends State<CodeEditor> {
  @override
  void initState() {
    super.initState();
    controller.fullText = widget.code;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Code'),
      ),
      body: Column(
        children: [
          Expanded(
            child: CodeField(
              controller: controller,
            ),
          ),
        ],
      ),
    );
  }
}
