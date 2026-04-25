import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:bus_ticket_app/features/auth/viewmodels/auth_view_model.dart';
import 'package:bus_ticket_app/widgets/bottom_navigation.dart';

class OtpVerificationWidget extends StatefulWidget {
  final String contactInfo;

  const OtpVerificationWidget({Key? key, required this.contactInfo})
      : super(key: key);

  @override
  State<OtpVerificationWidget> createState() => _OtpVerificationScreeWidget();
}

class _OtpVerificationScreeWidget extends State<OtpVerificationWidget> {
  int _timerSeconds = 30;
  Timer? _timer;
  final TextEditingController _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  // Khởi động bộ đếm 30 giây
  void _startTimer() {
    setState(() => _timerSeconds = 30);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds == 0) {
        timer.cancel();
      } else {
        setState(() {
          _timerSeconds--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  // --- Hàm xử lý Xác nhận OTP ---
  Future<void> _onVerifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đủ 6 số OTP')),
      );
      return;
    }

    // Đóng bàn phím
    FocusScope.of(context).unfocus();

    final authVM = context.read<AuthViewModel>();
    final isSuccess = await authVM.verifyOtp(otp, widget.contactInfo);

    if (isSuccess && mounted) {
      // Đăng nhập thành công -> Lưu dữ liệu (đã làm trong ViewModel)
      // -> Chuyển sang Page khác (HomeScreen) và xóa lịch sử điều hướng
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const CustomBottonNav()),
        (Route<dynamic> route) => false,
      );
    }
  }

  // --- Hàm xử lý Gửi lại OTP ---
  Future<void> _onResendOtp() async {
    final authVM = context.read<AuthViewModel>();
    final isSuccess = await authVM.sendOtp(widget.contactInfo);

    if (isSuccess && mounted) {
      // Hiện thông báo đã gửi lại mã
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã gửi lại mã OTP thành công!'),
          backgroundColor: Colors.green,
        ),
      );
      // Khởi động lại bộ đếm 30s
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2073E8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<AuthViewModel>(
        builder: (context, authVM, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Xác thực mã OTP',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mã xác thực đã được gửi đến\n${widget.contactInfo}',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // Ô nhập OTP
                        TextField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          textAlign: TextAlign.center,
                          style:
                              const TextStyle(fontSize: 24, letterSpacing: 16),
                          onChanged: (_) {
                            // Xóa thông báo lỗi khi user bắt đầu gõ lại
                            if (authVM.errorMessage != null) {
                              authVM.clearError();
                            }
                          },
                          decoration: InputDecoration(
                            hintText: '------',
                            counterText: '',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Color(0xFF2073E8), width: 2),
                            ),
                          ),
                        ),

                        // Hiển thị lỗi từ ViewModel (nếu có)
                        if (authVM.errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            authVM.errorMessage!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Nút Xác nhận (Hiển thị loading nếu đang xử lý)
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F3260),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            // Vô hiệu hóa nút nếu đang loading
                            onPressed: authVM.isLoading ? null : _onVerifyOtp,
                            child: authVM.isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text(
                                    'Xác nhận',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Nút Gửi lại mã
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Chưa nhận được mã? ',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            GestureDetector(
                              // Cho phép bấm nếu đếm ngược về 0 VÀ không bị loading
                              onTap: (_timerSeconds == 0 && !authVM.isLoading)
                                  ? _onResendOtp
                                  : null,
                              child: Text(
                                _timerSeconds == 0
                                    ? 'Gửi lại ngay'
                                    : 'Gửi lại sau ${_timerSeconds}s',
                                style: TextStyle(
                                  color: _timerSeconds == 0
                                      ? const Color(0xFF2073E8)
                                      : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
