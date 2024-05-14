import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'user_data.dart';
import 'student_screen.dart';
import 'supervisor_screen.dart';

class LoginForm extends StatefulWidget {
  final UserType userType;

  const LoginForm({super.key, required this.userType});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Username',
            ),
          ),
          const SizedBox(height: 16.0),
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: 'Password',
            ),
            obscureText: true,
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () => _login(context),
            child: const Text('Login'),
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _login(BuildContext context) async {
    setState(() {
      _errorMessage = null;
    });

    const String url = 'http://127.0.0.1:5000/auth';
    final Map<String, String> body = {
      'username': _usernameController.text,
      'password': _passwordController.text,
      'userType':
          widget.userType == UserType.student ? 'student' : 'supervisor',
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Authentication successful
        final responseData = jsonDecode(response.body);
        final String userId = responseData['userId'];
        Provider.of<UserData>(context, listen: false)
            .setUser(userId, widget.userType);

        if (widget.userType == UserType.student) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StudentScreen()),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SupervisorScreen()),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Invalid username or password. Please try again.';
        });
      }
    } catch (e) {
      // Handle network errors
      print(e);
      setState(() {
        _errorMessage = 'Network error occurred. Please try again later.';
      });
    }
  }
}
