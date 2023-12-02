import 'package:flutter/material.dart';

import 'my_home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      darkTheme: ThemeData.dark(),
      theme: ThemeData.light(),
      title: 'Client',
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final serverIp = TextEditingController();
  final username = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Enter Server Ip'),
            SizedBox(
              child: TextField(
                controller: serverIp,
              ),
            ),
            const Text('Enter Username'),
            TextField(
              controller: username,
            ),
            const Divider(),
            TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MyHomePage(
                              userName: username.text,
                              serverIp: serverIp.text,
                            )));
              },
              child: const Text('Login'),
            )
          ],
        ),
      ),
    );
  }
}
