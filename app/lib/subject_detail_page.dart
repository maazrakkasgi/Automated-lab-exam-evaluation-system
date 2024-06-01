import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SubjectDetailPage extends StatefulWidget {
  final Map<String, dynamic> subject;

  SubjectDetailPage({required this.subject});

  @override
  _SubjectDetailPageState createState() => _SubjectDetailPageState();
}

class _SubjectDetailPageState extends State<SubjectDetailPage> {
  final _programNoController = TextEditingController();
  final _programInfoController = TextEditingController();
  final _testCaseController = TextEditingController();
  final _editIndexController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPrograms();
  }

  Future<void> _fetchPrograms() async {
    final response = await http.get(
      Uri.parse(
          'http://192.168.0.16:5000/get_programs?subject_id=${widget.subject['id']}'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> programs = json.decode(response.body);
      setState(() {
        widget.subject['programs'] = programs;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch programs')),
      );
    }
  }

  Future<void> _addProgram() async {
    final String programNo = _programNoController.text;
    final String programInfo = _programInfoController.text;
    final String testCases = _testCaseController.text;

    if (programNo.isNotEmpty &&
        programInfo.isNotEmpty &&
        testCases.isNotEmpty) {
      final response = await http.post(
        Uri.parse('http://192.168.0.16:5000/add_program'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'subject_id': widget.subject['id'],
          'program_no': programNo,
          'program_info': programInfo,
          'test_cases': testCases,
        }),
      );

      if (response.statusCode == 200) {
        _fetchPrograms(); // Refresh the list of programs
        _programNoController.clear();
        _programInfoController.clear();
        _testCaseController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add program')),
        );
      }
    }
  }

  Future<void> _updateProgram(int index) async {
    final String programNo = _programNoController.text;
    final String programInfo = _programInfoController.text;
    final String testCases = _testCaseController.text;
    final int programId = widget.subject['programs'][index]['id'];

    if (programNo.isNotEmpty &&
        programInfo.isNotEmpty &&
        testCases.isNotEmpty) {
      final response = await http.put(
        Uri.parse('http://192.168.0.16:5000/update_program/$programId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'program_no': programNo,
          'program_info': programInfo,
          'test_cases': testCases,
        }),
      );

      if (response.statusCode == 200) {
        _fetchPrograms(); // Refresh the list of programs
        _editIndexController.clear();
        _programNoController.clear();
        _programInfoController.clear();
        _testCaseController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update program')),
        );
      }
    }
  }

  Future<void> _deleteProgram(int index) async {
    final int programId = widget.subject['programs'][index]['id'];
    final response = await http.delete(
      Uri.parse('http://192.168.0.16:5000/delete_program/$programId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      _fetchPrograms(); // Refresh the list of programs
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete program')),
      );
    }
  }

  void _editProgram(int index) {
    setState(() {
      _editIndexController.text = index.toString();
      _programNoController.text =
          widget.subject['programs'][index]['program_no'];
      _programInfoController.text =
          widget.subject['programs'][index]['program_info'];
      _testCaseController.text =
          widget.subject['programs'][index]['test_cases'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject['name']),
        backgroundColor: Colors.lightBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Subject Code: ${widget.subject['code']}'),
            Text('Scheme: ${widget.subject['scheme']}'),
            const SizedBox(height: 20.0),
            TextField(
              controller: _programNoController,
              decoration: const InputDecoration(
                labelText: 'Program No',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10.0),
            TextField(
              controller: _programInfoController,
              decoration: const InputDecoration(
                labelText: 'Program Info',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10.0),
            TextField(
              controller: _testCaseController,
              maxLines: null, // Allow multiline input
              decoration: const InputDecoration(
                labelText: 'Test Cases',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10.0),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _editIndexController.text.isNotEmpty
                      ? () =>
                          _updateProgram(int.parse(_editIndexController.text))
                      : _addProgram,
                  child: Text(_editIndexController.text.isNotEmpty
                      ? 'Update Program'
                      : 'Add Program'),
                ),
                const SizedBox(width: 10.0),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _editIndexController.clear();
                      _programNoController.clear();
                      _programInfoController.clear();
                      _testCaseController.clear();
                    });
                  },
                  child: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            Expanded(
              child: ListView.builder(
                itemCount: widget.subject['programs'].length,
                itemBuilder: (context, index) {
                  final program = widget.subject['programs'][index];
                  return ListTile(
                    title: Text('Program No: ${program['program_no']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Info: ${program['program_info']}'),
                        Text('Test Cases: ${program['test_cases']}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editProgram(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteProgram(index),
                        ),
                      ],
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
