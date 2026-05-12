import 'package:bus_ticket_app/widgets/bottom_navigation.dart';
import 'package:flutter/material.dart';

class PaymentSuccessWidget extends StatelessWidget {
  final String orderId;
  final int totalPrice;
  final String contactEmail;
  final String busCompanyName;
  final String date;
  final String time;

  const PaymentSuccessWidget({
    super.key,
    required this.orderId,
    required this.totalPrice,
    required this.contactEmail,
    required this.busCompanyName,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPaymentInfo(),
                  const SizedBox(height: 16),
                  _buildLoyaltyPoints(),
                  const SizedBox(height: 16),
                  _buildWarningCard(),
                  const SizedBox(height: 24),
                  const Text(
                    'Thông tin chuyến đi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildTripInfoCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.blue[600],
      padding: const EdgeInsets.only(top: 48, bottom: 32, left: 16, right: 16),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const CustomBottonNav()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 40, color: Colors.blue),
          ),
          const SizedBox(height: 16),
          const Text(
            'Thanh toán thành công',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Thông tin chuyến đi đã được gửi đến\n$contactEmail, hãy kiểm tra nhé!',
            style: const TextStyle(color: Colors.white, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin thanh toán',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Trạng thái', 'Đã thanh toán', valueColor: Colors.green),
          const SizedBox(height: 12),
          _buildInfoRow('Phương thức thanh toán', 'Ví MoMo'),
          const SizedBox(height: 12),
          _buildInfoRow('Tổng tiền', _formatPrice(totalPrice), isBold: true),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.black,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildLoyaltyPoints() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDE7),
        border: Border.all(color: const Color(0xFFFFF9C4)),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildWarningCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[100]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(color: Colors.black87, fontSize: 12, height: 1.5),
                children: [
                  TextSpan(text: 'Cảnh báo: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                    text: 'Vexere KHÔNG bao giờ yêu cầu quý khách truy cập liên kết lạ, cung cấp mã OTP ngân hàng hoặc chuyển tiền vào tài khoản không đứng tên "Công ty TNHH TMDV Vexere". Vui lòng chỉ sử dụng ứng dụng Vexere hoặc website Vexere.com để kiểm tra thông tin vé và thanh toán.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.directions_bus, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                'vexere $time, $date',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton(onPressed: () {}, child: const Text('Chi tiết')),
            ],
          ),
          const Divider(),
          const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Nhấn vào biểu tượng trái tim trên chuyến xe để lưu và đặt lại nhanh hơn vào lần sau.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    return '${price.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}đ';
  }
}
