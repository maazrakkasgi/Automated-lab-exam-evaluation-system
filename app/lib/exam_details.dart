import 'package:app/exam_code_editor.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// Make sure to import the new code editor page

class ExamDetailPage extends StatefulWidget {
  final int examId;

  ExamDetailPage({required this.examId});

  @override
  _ExamDetailPageState createState() => _ExamDetailPageState();
}

class _ExamDetailPageState extends State<ExamDetailPage> {
  List<Map<String, dynamic>> submissions = [];

  @override
  void initState() {
    super.initState();
    fetchSubmissions();
  }

  Future<void> fetchSubmissions() async {
    final response = await http.get(Uri.parse(
        'http://192.168.0.16:5000/exams/${widget.examId}/submissions'));
    if (response.statusCode == 200) {
      setState(() {
        submissions =
            List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Details'),
      ),
      body: submissions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: submissions.length,
              itemBuilder: (context, index) {
                final submission = submissions[index];
                final student = submission['student'];
                final testCases = submission['test_cases'];
                int totalCases = testCases['total_cases'];
                int passedCases = testCases['test_cases']
                    .values
                    .where((testCase) => testCase['success'] as bool)
                    .length;
                double grade = (passedCases / totalCases) * 100;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title:
                        Text('Student: ${student['name']} (${student['usn']})'),
                    subtitle: Text('Grade: ${grade.toStringAsFixed(2)} / 100'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CodeEditorPage(
                            studentName: student['name'],
                            studentUsn: student['usn'],
                            code: submission['code'],
                            language: submission['language'],
                            testCases: submission['test_cases'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
