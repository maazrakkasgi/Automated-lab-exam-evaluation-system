import 'package:app/exam_details.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

class ExamsScreen extends StatefulWidget {
  @override
  _ExamsScreenState createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedSemester;
  int? selectedSubjectId;
  List<String> semesters = [];
  List<Map<String, dynamic>> subjects = [];
  List<Map<String, dynamic>> exams = [];

  @override
  void initState() {
    super.initState();
    fetchSemesters();
    fetchSubjects();
    fetchExams();
  }

  Future<void> fetchSemesters() async {
    final response =
        await http.get(Uri.parse('http://192.168.0.16:5000/semesters'));
    if (response.statusCode == 200) {
      setState(() {
        semesters = List<String>.from(json.decode(response.body));
      });
    }
  }

  Future<void> fetchSubjects() async {
    final response =
        await http.get(Uri.parse('http://192.168.0.16:5000/subjects'));
    if (response.statusCode == 200) {
      setState(() {
        subjects = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    }
  }

  Future<void> fetchExams() async {
    final response =
        await http.get(Uri.parse('http://192.168.0.16:5000/list_exams'));
    if (response.statusCode == 200) {
      setState(() {
        exams = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    }
  }

  Future<void> createExam() async {
    final response = await http.post(
      Uri.parse('http://192.168.0.16:5000/exams'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'semester': selectedSemester,
        'subject_id': selectedSubjectId,
      }),
    );

    if (response.statusCode == 201) {
      // Handle success
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exam created successfully')));
      fetchExams(); // Refresh the list of exams
    } else {
      // Handle error
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to create exam')));
    }
  }

  Future<void> deleteExam(int examId) async {
    final response = await http.delete(
      Uri.parse('http://192.168.0.16:5000/exams/$examId'),
    );

    if (response.statusCode == 200) {
      // Handle success
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exam deleted successfully')));
      fetchExams(); // Refresh the list of exams
    } else {
      // Handle error
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to delete exam')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Exams'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedSemester,
                    hint: const Text('Select Semester'),
                    items: semesters.map((String semester) {
                      return DropdownMenuItem<String>(
                        value: semester,
                        child: Text(semester),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedSemester = newValue;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Please select a semester' : null,
                    decoration: const InputDecoration(
                      labelText: 'Semester',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: selectedSubjectId,
                    hint: const Text('Select Subject'),
                    items: subjects.map((subject) {
                      return DropdownMenuItem<int>(
                        value: subject['id'],
                        child: Text(subject['name']),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedSubjectId = newValue;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Please select a subject' : null,
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        createExam();
                      }
                    },
                    child: const Text('Create Exam'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: exams.length,
                itemBuilder: (context, index) {
                  final exam = exams[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text('Semester: ${exam['semester']}'),
                      subtitle: Text('Subject ID: ${exam['subject_id']}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          deleteExam(exam['id']);
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ExamDetailPage(examId: exam['id']),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
