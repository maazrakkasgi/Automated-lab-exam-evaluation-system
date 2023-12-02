import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:highlight/languages/python.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final controller = CodeController(
  text: '...', // Initial code
  language: python,
);

class CodeEditor extends StatefulWidget {
  const CodeEditor({super.key, required this.username, required this.serverIp});
  final String username;
  final String serverIp;

  @override
  State<CodeEditor> createState() => _CodeEditorState();
}

class _CodeEditorState extends State<CodeEditor> {
  void apiservice() async {
    String text = controller.text;
    String username = widget.username;
    var url = Uri.parse(
        'http://${widget.serverIp}:8000/add'); // Replace with your actual API URL
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'text': text,
      }),
    );

    if (response.statusCode == 200) {
      print('Item added successfully');
    } else {
      throw Exception('Failed to add item');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: CodeField(
              controller: controller,
            ),
          ),
          FloatingActionButton(
            onPressed: () {
              apiservice();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Submitted Successfully'),
              ));
            },
            child: const Icon(Icons.send),
          )
        ],
      ),
    );
  }
}
