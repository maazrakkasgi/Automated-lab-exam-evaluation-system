import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'add_student_screen.dart';

class StudentInfoScreen extends StatefulWidget {
  const StudentInfoScreen({super.key});

  @override
  _StudentInfoScreenState createState() => _StudentInfoScreenState();
}

class _StudentInfoScreenState extends State<StudentInfoScreen> {
  List<dynamic> _students = [];
  bool _isLoading = false;
  String _selectedSemester = '1'; // Default semester filter

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.get(Uri.parse(
        'http://127.0.0.1:5000/students?semester=$_selectedSemester'));
    if (response.statusCode == 200) {
      setState(() {
        _students = jsonDecode(response.body);
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to load students');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Information'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddStudentScreen()),
              ).then((value) {
                if (value == true) {
                  _fetchStudents();
                }
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _students.isEmpty
              ? const Center(child: Text('No students found'))
              : ListView.builder(
                  itemCount: _students.length,
                  itemBuilder: (context, index) {
                    final student = _students[index];
                    return ListTile(
                      title: Text(student['name']),
                      subtitle: Text(
                          'DOB: ${student['dob']}\nUSN: ${student['usn']}\nSemester: ${student['semester']}'),
                    );
                  },
                ),
    );
  }

  Future<void> _showFilterDialog() async {
    final selectedSemester = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter by Semester'),
          content: DropdownButtonFormField<String>(
            value: _selectedSemester,
            hint: const Text('Select Semester'),
            onChanged: (newValue) {
              setState(() {
                _selectedSemester = newValue!;
              });
            },
            items: <String>['3', '4', '5', '6', '7', '8']
                .map<DropdownMenuItem<String>>(
                  (String value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text('Semester $value'),
                  ),
                )
                .toList(),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                _fetchStudents();
                Navigator.pop(context, _selectedSemester);
              },
              child: const Text('APPLY'),
            ),
          ],
        );
      },
    );

    if (selectedSemester != null) {
      setState(() {
        _selectedSemester = selectedSemester;
      });
    }
  }
}
