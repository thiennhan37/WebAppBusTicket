import 'package:bus_ticket_app/features/booking/viewmodel/seat_selection_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentSelectionWidget extends StatelessWidget {
  const PaymentSelectionWidget({super.key});

  Future<void> _handleMomoPayment(SeatSelectionViewModel viewModel) async {
    // Gọi API payment (ViewModel đã có logic chỉ gửi request 1 lần)
    final success = await viewModel.processPayment();
    
    if (success && viewModel.paymentData != null) {
      final deeplink = viewModel.paymentData!['qrCodeUrl'] ?? viewModel.paymentData!['deeplink'];
      final payUrl = viewModel.paymentData!['payUrl'];

      // Thử mở ứng dụng MoMo bằng qrCodeUrl (deeplink) hoặc payUrl
      String? urlToOpen = deeplink ?? payUrl;
      
      if (urlToOpen != null && urlToOpen.isNotEmpty) {
        final url = Uri.parse(urlToOpen);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
          return;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SeatSelectionViewModel>();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Thanh đếm ngược thời gian
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: const Color(0xFFFFF8E1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Thời gian thanh toán còn lại ',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                Text(
                  viewModel.remainingTimeFormatted,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[900],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. Thông báo bảo mật
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    border: Border.all(color: const Color(0xFFC8E6C9)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Nhiều cách thanh toán, bảo mật tuyệt đối.',
                          style: TextStyle(color: Colors.green[900], fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Phương thức thanh toán',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // 4. Lựa chọn MoMo
                _buildPaymentOption(
                  context,
                  id: 'momo',
                  title: 'Ví MoMo',
                  subtitle: 'Thanh toán qua ứng dụng MoMo',
                  icon: Icons.account_balance_wallet,
                  iconColor: Colors.pink,
                  isSelected: viewModel.selectedPaymentMethod == 'momo',
                  onTap: () {
                    viewModel.selectPaymentMethod('momo');
                    _handleMomoPayment(viewModel);
                  },
                ),

                // HIỂN THỊ QR CODE CHO MOMO SỬ DỤNG qr_flutter
                if (viewModel.selectedPaymentMethod == 'momo') ...[
                  if (viewModel.isLoading && viewModel.paymentData == null)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (viewModel.paymentData != null)
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey[200]!),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Quét mã QR để thanh toán',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 12),
                            // Sử dụng QrImageView để tạo mã QR từ chuỗi qrCodeUrl (momo://...)
                            QrImageView(
                              data: viewModel.paymentData!['qrCodeUrl'] ?? '',
                              version: QrVersions.auto,
                              size: 200.0,
                              backgroundColor: Colors.white,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Sử dụng App MoMo để quét mã',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],

                const SizedBox(height: 12),

                // 5. Lựa chọn VNPAY
                _buildPaymentOption(
                  context,
                  id: 'vnpay',
                  title: 'VNPAY',
                  subtitle: 'Thanh toán qua QR-Code hoặc thẻ nội địa',
                  icon: Icons.qr_code_scanner,
                  iconColor: Colors.blue,
                  isSelected: viewModel.selectedPaymentMethod == 'vnpay',
                  onTap: () => viewModel.selectPaymentMethod('vnpay'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
    BuildContext context, {
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Colors.blue[50] : Colors.white,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.blue)
            else
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[400]!),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
