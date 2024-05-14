import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_data.dart';

class StudentScreen extends StatelessWidget {
  const StudentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome, Student!'),
            Text('User ID: ${userData.userId}'),
          ],
        ),
      ),
    );
  }
}
