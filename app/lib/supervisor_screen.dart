import 'package:app/subjects_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_data.dart';
import 'student_info_screen.dart';
import 'exams_screen.dart';
import 'grades_screen.dart';

class SupervisorScreen extends StatelessWidget {
  const SupervisorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supervisor Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome, Supervisor!'),
            Text('User ID: ${userData.userId}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const StudentInfoScreen()),
                );
              },
              child: const Text('Students Info'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ExamsScreen()),
                );
              },
              child: const Text('Exams'),
            ),
            const SizedBox(height: 10),
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => const GradesScreen()),
            //     );
            //   },
            //   child: const Text('Grades'),
            // ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SubjectsPage()),
                );
              },
              child: const Text('Subjects'),
            ),
          ],
        ),
      ),
    );
  }
}
