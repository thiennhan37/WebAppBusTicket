import 'package:bus_ticket_app/data/services/local/auth_storage.dart';
import 'package:bus_ticket_app/features/auth/viewmodels/auth_view_model.dart';
import 'package:bus_ticket_app/features/customer/viewmodels/profile_viewmodel.dart';
import 'package:bus_ticket_app/pages/login_page.dart';
import 'package:bus_ticket_app/widgets/account_info_widgets/custom_input_field.dart';
import 'package:bus_ticket_app/widgets/account_info_widgets/infor_banner.dart';
import 'package:bus_ticket_app/widgets/bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../data/models/update_customer_profile_request_model.dart';
import '../core/storage/storage_service.dart';
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
    // TODO: implement initState
    super.initState();
    _selectedCountry = _countries[0];
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
        _selectedCountry = _countries.firstWhere(
          (country) => country['code'] == idRegion,
          orElse: () => _countries[0],
        );
      }
    }
  }

  String _getAvatarText() {
    if (_fullName.trim().isEmpty) return 'U'; // U = User (Mặc định)
    List<String> nameParts = _fullName.trim().split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[nameParts.length - 2][0]}${nameParts.last[0]}'
          .toUpperCase();
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
            final bottomNav =
                context.findAncestorStateOfType<CustomBottonNavState>();
            bottomNav?.changeTab(0);
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'Thông tin tài khoản',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _showLogoutConfirmDialog(context);
            },
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
          const SizedBox(height: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InforBanner(
              text:
                  'Bổ sung đầy đủ thông tin sẽ giúp Vexere hỗ trợ bạn tốt hơn khi đặt vé.',
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
                  style: const TextStyle(
                    fontSize: 64,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
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
              children: [
                // Ô mã quốc gia
                InkWell(
                  onTap: _showCountryPicker,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Text(
                          _selectedCountry['flag']!,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          '${_selectedCountry['code']}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 4.0),
                        const Icon(Icons.arrow_drop_down, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Ô nhập số
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
              text:
                  'Thông tin đơn hàng sẽ được gửi đến số điện thoại và email bạn cung cấp.',
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
              suffixIcon: const Icon(
                Icons.calendar_today_outlined,
                color: Colors.black87,
              ),
              onChanged: (value) => _dob = value,
            ),

            const SizedBox(height: 24),

            // Form: Giới tính
            const Text(
              'Giới tính',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            const GenderSelector(),

            const SizedBox(height: 32),

            // Nút LƯU
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D2E59), // Màu xanh đen đậm
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  _handleSave();
                },
                child: const Text(
                  'Lưu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

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

  Future<void> _handleSave() async {
    print('--- ĐANG LƯU THÔNG TIN ---');

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
      return; // Dừng lại không gọi API nếu ngày sinh sai
    }

    final requestData = UpdateCustomerProfileRequestModel(
      fullName: _fullName,
      phone: _phoneNumber,
      email: _email,
      dob: parsedDob, // Đưa DateTime vào đây
      gender: _gender,
      idRegion: _selectedCountry['code'] ?? '+84',
    );

    final isSuccess = await viewModel.saveProfile(requestData);

    if (!mounted) return;

    if (isSuccess) {
      final storage = GetIt.I<AuthStorage >();
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
        const SnackBar(
          content: Text('Cập nhật thông tin thành công!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Cập nhật thất bại'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showLogoutConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Xác nhận đăng xuất',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text(
              'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản này không?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Tắt popup
              },
              child: const Text('Hủy',
                  style: TextStyle(color: Colors.grey, fontSize: 16)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Tắt popup trước
                _handleLogout(context); // Tiến hành đăng xuất
              },
              child: const Text('Đăng xuất',
                  style: TextStyle(color: Colors.red, fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final viewModel = GetIt.I<AuthViewModel>();
    await viewModel.logout();

    //Chuyển về trang Login và XÓA SẠCH lịch sử trang (tránh người dùng vuốt Back quay lại)
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false, // false nghĩa là xóa hết tất cả các route trước đó
      );
    }
  }
}
