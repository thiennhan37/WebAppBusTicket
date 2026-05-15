import 'package:bus_ticket_app/core/constants/country_constants.dart';
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
  const AccountInfoPages({super.key});

  @override
  State<AccountInfoPages> createState() => _AccountInfoPageState();
}

class _AccountInfoPageState extends State<AccountInfoPages> {
  final ProfileViewModel viewModel = GetIt.I<ProfileViewModel>();
  String _fullName = '';
  String _phoneNumber = '';
  String _email = '';
  String _dob = '';
  String _gender = 'Nam';

  late Map<String, String> _selectedCountry;

  @override
  void initState() {
    super.initState();
    _selectedCountry = CountryConstants.countries[0];
    _loadUserData();
  }

  void _loadUserData() {
    final storage = GetIt.I<AuthStorage>();
    final userInfo = storage.getUserInfo();

    if (userInfo != null) {
      _fullName = userInfo['fullName'] ?? '';
      _phoneNumber = userInfo['phone'] ?? '';
      _email = userInfo['email'] ?? '';
      _dob = userInfo['dob'] ?? '';
      _gender = userInfo['gender'] ?? 'Nam';
      final String? idRegion = userInfo['idRegion'];

      if (idRegion != null && idRegion.isNotEmpty) {
        _selectedCountry = CountryConstants.countries.firstWhere(
          (country) => country['code'] == idRegion,
          orElse: () => CountryConstants.countries[0],
        );
      }
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
            final bottomNav = context.findAncestorStateOfType<CustomBottonNavState>();
            bottomNav?.changeTab(0);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'Thông tin tài khoản',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
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
              suffixIcon: const Icon(Icons.calendar_today_outlined, color: Colors.black87),
              onChanged: (value) => _dob = value,
            ),
            const SizedBox(height: 24),
            const Text('Giới tính', style: TextStyle(fontSize: 14, color: Colors.black87)),
            const SizedBox(height: 12),
            const GenderSelector(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D2E59),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                onPressed: _handleSave,
                child: const Text(
                  'Lưu',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    DateTime parsedDob;
    try {
      if (_dob.trim().isEmpty) throw Exception();
      parsedDob = DateFormat('dd/MM/yyyy').parseStrict(_dob);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ngày sinh không hợp lệ. Vui lòng nhập đúng định dạng dd/MM/yyyy'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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
