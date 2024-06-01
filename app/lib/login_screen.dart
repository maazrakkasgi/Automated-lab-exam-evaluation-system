import 'package:flutter/material.dart';
import 'user_data.dart';
import 'login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Login'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Student'),
                Tab(text: 'Supervisor'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              LoginForm(userType: UserType.student),
              LoginForm(userType: UserType.supervisor),
            ],
          ),
        ),
      ),
    );
  }
}
