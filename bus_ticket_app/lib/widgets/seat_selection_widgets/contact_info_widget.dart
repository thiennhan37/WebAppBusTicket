import 'package:bus_ticket_app/core/constants/country_constants.dart';
import 'package:bus_ticket_app/data/services/local/auth_storage.dart';
import 'package:bus_ticket_app/features/booking/viewmodel/seat_selection_viewmodel.dart';
import 'package:bus_ticket_app/widgets/account_info_widgets/custom_input_field.dart';
import 'package:bus_ticket_app/widgets/common/country_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

class ContactInfoWidget extends StatefulWidget {
  const ContactInfoWidget({super.key});

  @override
  State<ContactInfoWidget> createState() => _ContactInfoWidgetState();
}

class _ContactInfoWidgetState extends State<ContactInfoWidget> {
  late Map<String, String> _selectedCountry;

  @override
  void initState() {
    super.initState();
    _selectedCountry = CountryConstants.countries[0];
    
    // Sử dụng addPostFrameCallback để tránh lỗi "setState during build"
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    if (!mounted) return;
    
    final storage = GetIt.I<AuthStorage>();
    final userInfo = storage.getUserInfo();
    final viewModel = context.read<SeatSelectionViewModel>();

    if (userInfo != null) {
      final String fullName = userInfo['fullName'] ?? '';
      final String phone = userInfo['phone'] ?? '';
      final String email = userInfo['email'] ?? '';
      final String? idRegion = userInfo['idRegion'];

      if (idRegion != null && idRegion.isNotEmpty) {
        setState(() {
          _selectedCountry = CountryConstants.countries.firstWhere(
            (country) => country['code'] == idRegion,
            orElse: () => CountryConstants.countries[0],
          );
        });
      }

      // Chỉ cập nhật nếu ViewModel chưa có dữ liệu
      if (viewModel.contactName.isEmpty) {
        viewModel.updateContactInfo(
          name: fullName,
          phone: phone,
          email: email,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SeatSelectionViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin liên hệ',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          
          CustomInputField(
            label: 'Họ và tên',
            isRequired: true,
            initValue: viewModel.contactName,
            onChanged: (val) => viewModel.updateContactInfo(name: val),
          ),
          const SizedBox(height: 24),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomInputField(
                  label: 'Số điện thoại',
                  isRequired: true,
                  initValue: viewModel.contactPhone,
                  keyboardInputType: TextInputType.phone,
                  onChanged: (val) => viewModel.updateContactInfo(phone: val),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          CustomInputField(
            label: 'Email',
            isRequired: true,
            initValue: viewModel.contactEmail,
            keyboardInputType: TextInputType.emailAddress,
            onChanged: (val) => viewModel.updateContactInfo(email: val),
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Thông tin đơn hàng sẽ được gửi đến số điện thoại và email bạn cung cấp.',
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Center(
            child: Column(
              children: [
                const Text(
                  'Bằng việc nhấn nút Tiếp tục, bạn đồng ý với',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Chính sách bảo mật thông tin', 
                        style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline, fontSize: 13)),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text('và', style: TextStyle(fontSize: 13, color: Colors.black54)),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Quy chế', 
                        style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline, fontSize: 13)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
