import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  _AddStudentScreenState createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _usnController = TextEditingController();
  final TextEditingController _semesterController = TextEditingController();

  Future<void> _addStudent() async {
    final String name = _nameController.text;
    final String dob = _dobController.text;
    final String usn = _usnController.text;
    final String semester = _semesterController.text;

    const String url = 'http://192.168.0.16:5000/students';
    final Map<String, String> body = {
      'name': name,
      'dob': dob,
      'usn': usn,
      'semester': semester,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode(body), // Encode the body to JSON
        headers: {
          'Content-Type': 'application/json'
        }, // Set Content-Type header
      );

      if (response.statusCode == 201) {
        Navigator.pop(context, true); // Navigate back to StudentInfoScreen
      } else {
        throw Exception('Failed to add student');
      }
    } catch (e) {
      throw Exception('Failed to add student');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Student'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _dobController,
              decoration:
                  const InputDecoration(labelText: 'Date of Birth (DOB)'),
              keyboardType: TextInputType.datetime, // Show date picker keyboard
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _usnController,
              decoration: const InputDecoration(
                  labelText: 'University Serial Number (USN)'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _semesterController,
              decoration: const InputDecoration(labelText: 'Semester'),
              keyboardType: TextInputType.number, // Show number keyboard
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _addStudent,
              child: const Text('Add Student'),
            ),
          ],
        ),
      ),
    );
  }
}
