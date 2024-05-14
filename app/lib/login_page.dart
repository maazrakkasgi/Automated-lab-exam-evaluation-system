import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: const Center(
        child: LoginTabs(),
      ),
      appBar: AppBar(
        title: const Text('Exam Login'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

class LoginTabs extends StatefulWidget {
  const LoginTabs({super.key});

  @override
  State<LoginTabs> createState() => _LoginTabsState();
}

class _LoginTabsState extends State<LoginTabs> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: Colors.white,
        child: const LoginForm(),
      ),
    );
  }
}

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'USN/ID',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20.0),
          TextFormField(
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () {
              // Implement login logic
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}
