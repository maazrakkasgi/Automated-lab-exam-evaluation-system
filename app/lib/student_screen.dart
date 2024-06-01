import 'package:app/code_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_data.dart';

class StudentScreen extends StatelessWidget {
  const StudentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);
    return const CodeEditorApp();
  }
}
