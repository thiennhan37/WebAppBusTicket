import 'package:bus_ticket_app/widgets/login_widgets/SocialLoginSection.dart';
import 'package:bus_ticket_app/widgets/login_widgets/header_login_widget.dart';
import 'package:bus_ticket_app/widgets/login_widgets/login_form.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const HeaderLoginWidget(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: const [
                  SizedBox(height: 16),
                  LoginForm(),
                  SizedBox(height: 32),
                  SocialLoginSection(),
                  SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
