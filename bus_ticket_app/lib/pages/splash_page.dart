import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/auth/viewmodels/auth_view_model.dart';
import '../widgets/bottom_navigation.dart';
import 'login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final authViewModel = context.read<AuthViewModel>();

    // Đợi quá trình check token hoàn tất (có thể thêm delay 1s để logo hiện rõ nếu API chạy quá nhanh)
    await Future.delayed(const Duration(seconds: 1));
    final isLoggedIn = await authViewModel.tryAutoLogin();

    if (!mounted) return;

    // Rẽ nhánh màn hình
    if (isLoggedIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const CustomBottonNav()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.blue, // Đổi màu nền theo theme app của bạn
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Sửa lại thành logo thật của bạn
            Icon(Icons.directions_bus, size: 80, color: Colors.white),
            SizedBox(height: 16),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}