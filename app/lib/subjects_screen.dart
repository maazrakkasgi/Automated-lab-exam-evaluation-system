import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'subject_detail_page.dart';

class SubjectsPage extends StatefulWidget {
  @override
  _SubjectsPageState createState() => _SubjectsPageState();
}

class _SubjectsPageState extends State<SubjectsPage> {
  final TextEditingController _subjectNameController = TextEditingController();
  final TextEditingController _subjectCodeController = TextEditingController();
  final TextEditingController _subjectSchemeController =
      TextEditingController();

  List<Map<String, dynamic>> subjects = [];

  Future<void> _addSubject() async {
    final String name = _subjectNameController.text;
    final String code = _subjectCodeController.text;
    final String scheme = _subjectSchemeController.text;
    if (name.isNotEmpty && code.isNotEmpty && scheme.isNotEmpty) {
      final response = await http.post(
        Uri.parse('http://192.168.0.16:5000/add_subject'),
        body: jsonEncode({'name': name, 'code': code, 'scheme': scheme}),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        setState(() {
          subjects.add({
            'name': name,
            'code': code,
            'scheme': scheme,
            'programs': [],
          });
          _subjectNameController.clear();
          _subjectCodeController.clear();
          _subjectSchemeController.clear();
        });
      } else {
        // Handle error
      }
    }
  }

  Future<void> _fetchSubjects() async {
    final response = await http.get(
      Uri.parse('http://192.168.0.16:5000/subjects'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> subjectsData = jsonDecode(response.body);
      setState(() {
        subjects = subjectsData
            .map((subject) => subject as Map<String, dynamic>)
            .toList();
      });
    } else {
      // Handle error
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchSubjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subjects Management'),
        backgroundColor: Colors.lightBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _subjectNameController,
              decoration: const InputDecoration(
                labelText: 'Subject Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10.0),
            TextField(
              controller: _subjectCodeController,
              decoration: const InputDecoration(
                labelText: 'Subject Code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10.0),
            TextField(
              controller: _subjectSchemeController,
              decoration: const InputDecoration(
                labelText: 'Scheme',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: _addSubject,
              child: const Text('Add Subject'),
            ),
            const SizedBox(height: 20.0),
            Expanded(
              child: ListView.builder(
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  final subject = subjects[index];
                  return ListTile(
                    title: Text(subject['name']),
                    subtitle: Text(
                        'Code: ${subject['code']} | Scheme: ${subject['scheme']}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SubjectDetailPage(subject: subject),
                        ),
                      );
                    },
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
