import 'package:bus_ticket_app/widgets/account_info_widgets/custom_input_field.dart';
import 'package:bus_ticket_app/widgets/account_info_widgets/infor_banner.dart';
import 'package:flutter/material.dart';

import '../widgets/account_info_widgets/gender_selector_state.dart';

class AccountInfoPage extends StatefulWidget {
  const AccountInfoPage({super.key});

  @override
  State<AccountInfoPage> createState() => _AccountInfoPageState();
}

class _AccountInfoPageState extends State<AccountInfoPage> {
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
          onPressed: () {},
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
              initValue: 'ABC',
            ),

            const SizedBox(height: 24),
            Row(
              children: [
                // Ô mã quốc gia
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      // Bạn có thể dùng CircleAvatar kết hợp Image.asset cho lá cờ thực tế
                      Container(
                        width: 20,
                        height: 14,
                        color: Colors.red, // Mô phỏng cờ VN
                        child: const Center(
                          child: Icon(
                            Icons.star,
                            color: Colors.yellow,
                            size: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '(+84)',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down, size: 20),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Ô nhập số
                const Expanded(
                  child: CustomInputField(
                    label: 'Số điện thoại',
                    isRequired: true,
                    initValue: '0706110630',
                    keyboardInputType: TextInputType.phone,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const CustomInputField(
              label: 'Email',
              isRequired: true,
              hintText: '',
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
            const CustomInputField(
              isRequired: true,
              label: 'Ngày sinh',
              initValue: '17/01/2005',
              suffixIcon: Icon(
                Icons.calendar_today_outlined,
                color: Colors.black87,
              ),
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
                  // Xử lý lưu thông tin
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
}
