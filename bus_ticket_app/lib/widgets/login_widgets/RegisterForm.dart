import 'package:bus_ticket_app/core/di/service_locator.dart';
import 'package:bus_ticket_app/features/auth/viewmodels/auth_view_model.dart';
import 'package:bus_ticket_app/widgets/login_widgets/otp_verification_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../data/models/customer_register_request_model.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  DateTime? _selectedDate;

  final AuthViewModel viewModel = getIt<AuthViewModel>();

  // 1. Khai báo danh sách quốc gia và quốc gia đang chọn
  final List<Map<String, String>> _countries = [
    {'code': '+84', 'flag': '🇻🇳', 'name': 'Việt Nam'},
    {'code': '+1', 'flag': '🇺🇸', 'name': 'Hoa Kỳ'},
    {'code': '+44', 'flag': '🇬🇧', 'name': 'Vương quốc Anh'},
    {'code': '+81', 'flag': '🇯🇵', 'name': 'Nhật Bản'},
    {'code': '+82', 'flag': '🇰🇷', 'name': 'Hàn Quốc'},
    {'code': '+66', 'flag': '🇹🇭', 'name': 'Thái Lan'},
    {'code': '+65', 'flag': '🇸🇬', 'name': 'Singapore'},
  ];
  late Map<String, String> _selectedCountry;

  @override
  void initState() {
    super.initState();
    // Gán mặc định là Việt Nam khi mới mở form
    _selectedCountry = _countries[0];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  // 2. Hàm hiển thị Bottom Sheet chọn quốc gia
  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.only(top: 16),
          height: 400,
          child: Column(
            children: [
              const Text(
                'Chọn quốc gia/ Vùng lãnh thổ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _countries.length,
                  itemBuilder: (context, index) {
                    final country = _countries[index];
                    return ListTile(
                      leading: Text(
                        country['flag']!,
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(country['name']!),
                      trailing: Text(
                        country['code']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedCountry = country;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Logic kiểm tra tuổi (> 16)
  bool _isOver16(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age >= 16;
  }

  // Logic chọn ngày sinh
  Future<void> _selectDate(BuildContext context) async {
    final DateTime initialDate =
        DateTime.now().subtract(const Duration(days: 365 * 16));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      if (!_isOver16(picked)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bạn phải đủ 16 tuổi trở lên để đăng ký.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _selectedDate = picked;
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
      if (viewModel.errorMessage != null) viewModel.clearError();
    }
  }

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
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

    final String countryCode = _selectedCountry['code'] ?? '+84';

    String formattedDob = DateFormat('dd/MM/yyyy').format(_selectedDate!);

    final registerRequest = CustomerRegisterRequestModel(
      fullName: name,
      email: email,
      phone: phone,
      idRegion: countryCode,
      dob: formattedDob,
    );

    // 4. Gọi hàm ViewModel
    bool isSuccess = await viewModel.sendRegistrationOtp(registerRequest);

    if (isSuccess) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerificationWidget(
            contactInfo: email,
            isRegister: true,
            registerData:
                registerRequest, // Truyền đầy đủ data để lúc Resend OTP còn có mã vùng
          ),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              viewModel.errorMessage ?? 'Đăng ký thất bại, vui lòng thử lại'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? prefixIcon,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        inputFormatters: inputFormatters,
        textCapitalization: textCapitalization,
        onChanged: (_) {
          if (viewModel.errorMessage != null) viewModel.clearError();
        },
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: prefixIcon,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        return Column(
          children: [
            if (viewModel.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  viewModel.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            _buildTextField(
              controller: _nameController,
              hintText: 'Họ và tên',
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
            ),
            _buildTextField(
              controller: _emailController,
              hintText: 'Nhập địa chỉ Gmail',
              keyboardType: TextInputType.emailAddress,
            ),
            _buildTextField(
              controller: _phoneController,
              hintText: 'Số điện thoại',
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              prefixIcon: InkWell(
                onTap: _showCountryPicker, // Mở bottom sheet khi bấm vào cờ
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                          '${_selectedCountry['flag']} (${_selectedCountry['code']})',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down, color: Colors.grey),
                      // Thêm mũi tên nhỏ báo hiệu có thể bấm
                      const SizedBox(width: 4),
                      Container(height: 24, width: 1, color: Colors.grey),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
            ),
            _buildTextField(
              controller: _dobController,
              hintText: 'Ngày sinh (DD/MM/YYYY)',
              readOnly: true,
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: viewModel.isLoading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D2E59),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                  disabledBackgroundColor:
                      const Color(0xFF0D2E59).withOpacity(0.6),
                ),
                child: viewModel.isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text(
                        'Đăng ký',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
