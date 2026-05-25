import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../features/auth/viewmodels/auth_view_model.dart';
import '../bottom_navigation.dart';

class SocialLoginSection extends StatelessWidget {
  final bool isLogin;
  final VoidCallback? onToggleAuth;

  const SocialLoginSection({
    super.key,
    this.isLogin = true,
    this.onToggleAuth,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey.shade300)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'hoặc',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey.shade300)),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () async {
              final authVM = context.read<AuthViewModel>();
              
              // Gọi login hoặc register tùy vào trạng thái isLogin
              final success = isLogin 
                  ? await authVM.loginWithGoogle() 
                  : await authVM.registerWithGoogle();

              if (!context.mounted) return;

              if (success) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const CustomBottonNav()),
                      (route) => false,
                );
              } else if (authVM.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(authVM.errorMessage!)),
                );
              }
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  child: SvgPicture.asset(
                    'assets/images/google.svg',
                    height: 30,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Tiếp tục với Google',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isLogin ? 'Bạn chưa có tài khoản? ' : 'Bạn đã có tài khoản? ',
              style: const TextStyle(color: Colors.black87),
            ),
            GestureDetector(
              onTap: onToggleAuth,
              child: Text(
                isLogin ? 'Đăng ký' : 'Đăng nhập',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
