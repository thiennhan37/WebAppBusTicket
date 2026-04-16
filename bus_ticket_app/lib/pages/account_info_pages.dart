import 'package:bus_ticket_app/pages/home_pages.dart';
import 'package:bus_ticket_app/widgets/account_info_widgets/custom_input_field.dart';
import 'package:bus_ticket_app/widgets/account_info_widgets/infor_banner.dart';
import 'package:bus_ticket_app/widgets/bottom_navigation.dart';
import 'package:flutter/material.dart';

import '../widgets/account_info_widgets/gender_selector_state.dart';

class AccountInfoPages extends StatefulWidget {
  const AccountInfoPages({super.key});

  @override
  State<AccountInfoPages> createState() => _AccountInfoPageState();
}

class _AccountInfoPageState extends State<AccountInfoPages> {
  String _fullName = 'Trần Tấn Phát';
  String _phoneNumber = '0706110630';
  String _email = '';
  String _dob = '17/01/2005';
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
            final bottomNav = context
                .findAncestorStateOfType<CustomBottonNavState>();
            bottomNav?.changeTab(0);
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          'Thông tin tài khoản',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {},
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
                  'TP',
                  style: TextStyle(
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
              hintText: _email,
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
              suffixIcon: Icon(
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

  void _handleSave() {
    print('--- THÔNG TIN ĐÃ LƯU ---');
    print('Tên: $_fullName');
    print('SĐT: ${_selectedCountry['code']} $_phoneNumber');
    print('Email: $_email');
    print('Ngày sinh: $_dob');
    print('Giới tính: $_gender');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lưu thông tin thành công!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
