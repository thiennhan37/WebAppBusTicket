import 'package:bus_ticket_app/core/di/service_locator.dart';
import 'package:bus_ticket_app/features/auth/viewmodels/auth_view_model.dart';
import 'package:bus_ticket_app/widgets/login_widgets/otp_verification_widget.dart';
import 'package:flutter/material.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();

  // Lấy ViewModel từ GetIt
  final AuthViewModel viewModel = getIt<AuthViewModel>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Hàm xử lý khi bấm nút Đăng nhập
  Future<void> _handleLogin() async {
    // Ẩn bàn phím khi bấm đăng nhập
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập email')),
      );
      return;
    }

    final bool isValidGmail =
        RegExp(r'^[a-zA-Z0-9._]+@gmail\.com$').hasMatch(email);

    if (!isValidGmail) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Vui lòng nhập đúng định dạng Gmail (VD: abc@gmail.com)'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Gọi hàm sendOtp từ ViewModel
    final success = await viewModel.sendOtp(email);

    // Kiểm tra context còn tồn tại không trước khi dùng Navigator/ScaffoldMessenger (Rule của Flutter linter)
    if (!mounted) return;

    if (success) {
      // Thành công -> Chuyển sang màn hình nhập OTP
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => OtpVerificationWidget(contactInfo: email)));
    } else {
      // Lỗi -> Hiện SnackBar báo lỗi từ backend
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Có lỗi xảy ra'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sử dụng ListenableBuilder để lắng nghe sự thay đổi từ viewModel
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        return Column(
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              // Xóa lỗi khi user bắt đầu gõ lại
              onChanged: (_) {
                if (viewModel.errorMessage != null) {
                  viewModel.clearError();
                }
              },
              decoration: InputDecoration(
                hintText: 'Nhập địa chỉ Gmail',
                hintStyle: const TextStyle(color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                // Hiển thị khung đỏ nếu có lỗi từ ViewModel
                errorText: viewModel.errorMessage,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                // Nếu đang loading thì disable nút (gán null)
                onPressed: viewModel.isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D2E59),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                  // Đổi màu nút khi bị disable
                  disabledBackgroundColor:
                      const Color(0xFF0D2E59).withOpacity(0.6),
                ),
                // Chuyển đổi giữa Text và Vòng xoay Loading
                child: viewModel.isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Đăng nhập',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
