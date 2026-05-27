import 'package:bus_ticket_app/core/constants/country_constants.dart';
import 'package:bus_ticket_app/data/models/customer_info_model.dart';
import 'package:bus_ticket_app/data/services/local/auth_storage.dart';
import 'package:bus_ticket_app/features/auth/viewmodels/auth_view_model.dart';
import 'package:bus_ticket_app/features/customer/viewmodels/profile_viewmodel.dart';
import 'package:bus_ticket_app/pages/login_page.dart';
import 'package:bus_ticket_app/widgets/account_info_widgets/custom_input_field.dart';
import 'package:bus_ticket_app/widgets/account_info_widgets/infor_banner.dart';
import 'package:bus_ticket_app/widgets/bottom_navigation.dart';
import 'package:bus_ticket_app/widgets/common/country_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../data/models/update_customer_profile_request_model.dart';
import '../widgets/account_info_widgets/gender_selector_state.dart';
import 'package:intl/intl.dart';

class AccountInfoPages extends StatefulWidget {
  final bool isGoogleRegister;
  final String? googleEmail;
  final String? googleIdToken;
  final String? googleFullName;

  const AccountInfoPages({
    super.key,
    this.isGoogleRegister = false,
    this.googleEmail,
    this.googleIdToken,
    this.googleFullName,
  });

  @override
  State<AccountInfoPages> createState() => _AccountInfoPageState();
}

class _AccountInfoPageState extends State<AccountInfoPages> {
  final ProfileViewModel viewModel = GetIt.I<ProfileViewModel>();
  final AuthViewModel authViewModel = GetIt.I<AuthViewModel>();
  
  String _fullName = '';
  String _phoneNumber = '';
  String _email = '';
  String _dob = '';
  String _gender = 'MALE';

  late Map<String, String> _selectedCountry;

  @override
  void initState() {
    super.initState();
    _selectedCountry = CountryConstants.countries[0];
    if (widget.isGoogleRegister) {
      _email = widget.googleEmail ?? '';
      _fullName = widget.googleFullName ?? '';
    } else {
      _loadUserData();
    }
  }

  void _loadUserData() {
    final storage = GetIt.I<AuthStorage>();
    final userInfo = storage.getUserInfo();

    if (userInfo != null) {
      setState(() {
        _fullName = userInfo['fullName'] ?? '';
        _phoneNumber = userInfo['phone'] ?? '';
        _email = userInfo['email'] ?? '';
        
        String rawDob = userInfo['dob'] ?? '';
        if (rawDob.isNotEmpty) {
          try {
            if (rawDob.contains('-')) {
              DateTime dt = DateTime.parse(rawDob);
              _dob = DateFormat('dd/MM/yyyy').format(dt);
            } else {
              _dob = rawDob;
            }
          } catch (e) {
            _dob = rawDob;
          }
        }

        String rawGender = userInfo['gender'] ?? 'MALE';
        if (rawGender == 'Nam') _gender = 'MALE';
        else if (rawGender == 'Nữ') _gender = 'FEMALE';
        else if (rawGender == 'Khác') _gender = 'OTHER';
        else _gender = rawGender;

        final String? idRegion = userInfo['idRegion'];
        if (idRegion != null && idRegion.isNotEmpty) {
          _selectedCountry = CountryConstants.countries.firstWhere(
            (country) => country['code'] == idRegion,
            orElse: () => CountryConstants.countries[0],
          );
        }
      });
    }
  }

  String _getAvatarText() {
    if (_fullName.trim().isEmpty) return 'U';
    List<String> nameParts = _fullName.trim().split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[nameParts.length - 2][0]}${nameParts.last[0]}'.toUpperCase();
    }
    return nameParts.first.substring(0, 1).toUpperCase();
  }

  Future<void> _selectDate() async {
    DateTime initialDate;
    final now = DateTime.now();
    final sixteenYearsAgo = DateTime(now.year - 16, now.month, now.day);

    try {
      if (_dob.isNotEmpty) {
        initialDate = DateFormat('dd/MM/yyyy').parse(_dob);
      } else {
        initialDate = sixteenYearsAgo;
      }
    } catch (e) {
      initialDate = sixteenYearsAgo;
    }

    if (initialDate.isAfter(sixteenYearsAgo)) {
      initialDate = sixteenYearsAgo;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dob = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () {
            if (widget.isGoogleRegister) {
              Navigator.pop(context);
            } else {
              final bottomNav = context.findAncestorStateOfType<CustomBottonNavState>();
              bottomNav?.changeTab(0);
            }
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          widget.isGoogleRegister ? 'Hoàn tất đăng ký' : 'Thông tin tài khoản',
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (!widget.isGoogleRegister)
            TextButton(
              onPressed: () => _showLogoutConfirmDialog(context),
              child: const Text(
                'Đăng xuất',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InforBanner(
              text: 'Bổ sung đầy đủ thông tin sẽ giúp Vexere hỗ trợ bạn tốt hơn khi đặt vé.',
              iconData: Icons.info,
              backgroundColor: Colors.blue.shade50,
              borderColor: Colors.blue.shade200,
              iconColor: Colors.blue,
            ),
            const SizedBox(height: 24),
            Center(
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
                alignment: Alignment.center,
                child: Text(
                  _getAvatarText(),
                  style: const TextStyle(fontSize: 64, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
            CustomInputField(
              label: 'Họ và tên',
              isRequired: true,
              initValue: _fullName,
              onChanged: (value) => _fullName = value,
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CountryPickerWidget(
                  selectedCountry: _selectedCountry,
                  countries: CountryConstants.countries,
                  onCountrySelected: (country) {
                    setState(() {
                      _selectedCountry = country;
                    });
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomInputField(
                    label: 'Số điện thoại',
                    isRequired: true,
                    initValue: _phoneNumber,
                    keyboardInputType: TextInputType.phone,
                    onChanged: (value) => _phoneNumber = value,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomInputField(
              label: 'Email',
              isRequired: true,
              initValue: _email,
              readOnly: widget.isGoogleRegister,
              onChanged: (value) => _email = value,
            ),
            const SizedBox(height: 16),
            InforBanner(
              text: 'Thông tin đơn hàng sẽ được gửi đến số điện thoại và email bạn cung cấp.',
              iconData: Icons.check_circle,
              backgroundColor: Colors.green.shade50,
              borderColor: Colors.green.shade200,
              iconColor: Colors.green,
            ),
            const SizedBox(height: 16),
            CustomInputField(
              isRequired: true,
              label: 'Ngày sinh',
              initValue: _dob,
              readOnly: true,
              onTap: _selectDate,
              suffixIcon: const Icon(Icons.calendar_today_outlined, color: Colors.black87),
            ),
            const SizedBox(height: 24),
            const Text('Giới tính', style: TextStyle(fontSize: 14, color: Colors.black87)),
            const SizedBox(height: 12),
            GenderSelector(
              selectedGender: _gender,
              onChanged: (value) {
                setState(() {
                  _gender = value;
                });
              },
            ),
            const SizedBox(height: 32),
            ListenableBuilder(
              listenable: widget.isGoogleRegister ? authViewModel : viewModel,
              builder: (context, _) {
                final bool isLoading = widget.isGoogleRegister ? authViewModel.isLoading : viewModel.isLoading;
                return SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D2E59),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    onPressed: isLoading ? null : _handleSave,
                    child: isLoading
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(
                            widget.isGoogleRegister ? 'Tạo tài khoản' : 'Lưu',
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                );
              }
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (_fullName.trim().isEmpty || 
        _phoneNumber.trim().isEmpty || 
        _email.trim().isEmpty ||
        _dob.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ tất cả thông tin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    DateTime parsedDob;
    try {
      parsedDob = DateFormat('dd/MM/yyyy').parseStrict(_dob);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ngày sinh không hợp lệ. Vui lòng chọn lại'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final now = DateTime.now();
    int age = now.year - parsedDob.year;
    if (now.month < parsedDob.month || (now.month == parsedDob.month && now.day < parsedDob.day)) {
      age--;
    }

    if (age < 16) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn phải ít nhất 16 tuổi để tiếp tục'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (widget.isGoogleRegister) {
      final customerInfo = CustomerInfoModel(
        id: '', // Backend sẽ tạo ID
        email: _email,
        fullName: _fullName,
        phone: _phoneNumber,
        // SỬA TẠI ĐÂY: Chuyển sang định dạng dd/MM/yyyy để khớp với mong đợi của Backend
        dob: DateFormat('dd/MM/yyyy').format(parsedDob),
        gender: _gender,
        idRegion: _selectedCountry['code'] ?? '+84',
      );

      final success = await authViewModel.completeGoogleRegister(widget.googleIdToken!, customerInfo);
      if (success) {
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const CustomBottonNav()),
          (route) => false,
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authViewModel.errorMessage ?? 'Đăng ký thất bại'), backgroundColor: Colors.red),
        );
      }
    } else {
      final requestData = UpdateCustomerProfileRequestModel(
        fullName: _fullName,
        phone: _phoneNumber,
        email: _email,
        dob: parsedDob,
        gender: _gender,
        idRegion: _selectedCountry['code'] ?? '+84',
      );

      final isSuccess = await viewModel.saveProfile(requestData);

      if (!mounted) return;

      if (isSuccess) {
        final storage = GetIt.I<AuthStorage>();
        Map<String, dynamic> userInfo = storage.getUserInfo() ?? {};
        userInfo['fullName'] = _fullName;
        userInfo['phone'] = _phoneNumber;
        userInfo['email'] = _email;
        userInfo['dob'] = _dob;
        userInfo['gender'] = _gender;
        userInfo['idRegion'] = _selectedCountry['code'];
        await storage.saveUserInfo(userInfo);

        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thông tin thành công!'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(viewModel.errorMessage ?? 'Cập nhật thất bại'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showLogoutConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Xác nhận đăng xuất', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi tài khoản này không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy', style: TextStyle(color: Colors.grey, fontSize: 16)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _handleLogout(context);
              },
              child: const Text('Đăng xuất', style: TextStyle(color: Colors.red, fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final authViewModel = GetIt.I<AuthViewModel>();
    await authViewModel.logout();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }
}
