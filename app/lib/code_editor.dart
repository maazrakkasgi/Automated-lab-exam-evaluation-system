import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:highlight/languages/java.dart';
import 'package:highlight/languages/python.dart';
import 'package:highlight/languages/cpp.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'user_data.dart';

class CodeEditorApp extends StatelessWidget {
  const CodeEditorApp();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Code Editor'),
        backgroundColor: Colors.lightBlue,
      ),
      body: CodeEditor(),
    );
  }
}

class CodeEditor extends StatefulWidget {
  @override
  _CodeEditorState createState() => _CodeEditorState();
}

class _CodeEditorState extends State<CodeEditor> {
  String? subjectID;
  bool isLoading = true;
  bool showTestCases = false;
  Map<String, dynamic>? testCaseResults;
  List<Map<String, dynamic>> programs = [];
  String? selectedProgramNo;
  String programInfo = '';

  final controller = CodeController(
    text: '',
    language: python,
  );

  String selectedLanguage = 'python';
  Map<String, dynamic> languages = {
    'python': python,
    'java': java,
    'c++': cpp,
  };

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    final userData = Provider.of<UserData>(context, listen: false);
    final userID = userData.userId;
    final userType = userData.userType;

    if (userID == null || userType == null) {
      throw Exception('User ID or User Type not available');
    }

    final response = await http.get(
      Uri.parse('http://192.168.0.16:5000/get_exam?usn_id=$userID'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        subjectID = data['subject_id'].toString();
        _fetchPrograms(); // Fetch programs once subjectID is available
      });
    } else {
      throw Exception('Failed to load initial data');
    }
  }

  Future<void> _fetchPrograms() async {
    if (subjectID == null) return;

    final response = await http.get(
      Uri.parse('http://192.168.0.16:5000/get_programs?subject_id=$subjectID'),
    );

    if (response.statusCode == 200) {
      setState(() {
        programs = List<Map<String, dynamic>>.from(json.decode(response.body));
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load programs');
    }
  }

  Future<void> _submitCode() async {
    final userData = Provider.of<UserData>(context, listen: false);
    final String? usn = userData.userId;

    if (usn == null || selectedProgramNo == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('User ID or Program No not available.')));
      return;
    }

    final String code = controller.text;
    print(selectedProgramNo);

    final response = await http.post(
      Uri.parse('http://192.168.0.16:5000/submit_code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'code': code,
        'usn': usn,
        'subject_id': subjectID,
        'language': selectedLanguage,
        'program_no': selectedProgramNo,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        testCaseResults = jsonDecode(response.body);
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Code submitted successfully!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit code.')));
    }
  }

  void _onProgramNoChanged(String? newValue) {
    setState(() {
      selectedProgramNo = newValue;
      if (newValue != null) {
        final selectedProgram =
            programs.firstWhere((program) => program['program_no'] == newValue);
        programInfo = selectedProgram['program_info'];
      } else {
        programInfo = '';
      }
    });
  }

  Widget _buildTestCaseResults() {
    if (testCaseResults == null) {
      return Container(
        child: const Text('No test case results to display.'),
      );
    }

    List<Widget> testCaseWidgets = [];
    Map<String, dynamic>? testCases = testCaseResults!['test_cases'];

    if (testCases != null) {
      testCases.forEach((key, value) {
        bool isSuccess = value['success'] == true;
        testCaseWidgets.add(
          Card(
            child: ListTile(
              leading: isSuccess
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : const Icon(Icons.error, color: Colors.red),
              title: Text('Test Case $key'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Time Taken: ${value['time_taken']}'),
                  const SizedBox(height: 5),
                  Text('Expected Output:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('${value['expected_output']}'),
                  const SizedBox(height: 5),
                  Text('Output:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('${value['output']}'),
                  const SizedBox(height: 5),
                  Text('Error: ${value['Error']}'),
                ],
              ),
            ),
          ),
        );
      });
    } else {
      testCaseWidgets.add(
        Container(
          child: const Text('Test cases data is missing or malformed.'),
        ),
      );
    }

    return Expanded(
      child: ListView(
        children: testCaseWidgets,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            value: selectedLanguage,
            items: languages.keys.map((String language) {
              return DropdownMenuItem<String>(
                value: language,
                child: Text(language),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                selectedLanguage = newValue!;
                controller.language = languages[newValue]!;
              });
            },
            decoration: const InputDecoration(
              labelText: 'Select Programming Language',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: selectedProgramNo,
            hint: const Text('Select Program No'),
            items: programs.map<DropdownMenuItem<String>>((program) {
              return DropdownMenuItem<String>(
                value: program['program_no'],
                child: Text('Program No: ${program['program_no']}'),
              );
            }).toList(),
            onChanged: _onProgramNoChanged,
            decoration: const InputDecoration(
              labelText: 'Select Program No',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          Text('Program Info: $programInfo'),
          const SizedBox(height: 10),
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
          ElevatedButton(
            onPressed: _submitCode,
            child: const Text('Submit Code'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              setState(() {
                showTestCases = !showTestCases;
              });
            },
            child: Text(showTestCases ? 'Hide Test Cases' : 'Show Test Cases'),
          ),
          if (showTestCases) _buildTestCaseResults(),
        ],
      ),
    );
  }
}
