import 'package:bus_ticket_app/widgets/login_widgets/RegisterForm.dart';
import 'package:bus_ticket_app/widgets/login_widgets/SocialLoginSection.dart';
import 'package:bus_ticket_app/widgets/login_widgets/header_login_widget.dart';
import 'package:bus_ticket_app/widgets/login_widgets/login_form.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const HeaderLoginWidget(
              title: 'Xin Chào',
              subtitle: 'Đăng kí để nhận nhiều ưu đãi',
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const RegisterForm(),
                  const SizedBox(height: 32),
                  SocialLoginSection(
                    isLogin: false,
                    onToggleAuth: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
