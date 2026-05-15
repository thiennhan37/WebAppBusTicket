import 'package:bus_ticket_app/data/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class TicketCardWidget extends StatelessWidget {
  final OrderModel order;

  const TicketCardWidget({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    DateTime departureDateTime = DateTime.parse(order.departureTime);
    String timeStr = DateFormat('HH:mm').format(departureDateTime);
    String dateStr = DateFormat('dd/MM/yyyy').format(departureDateTime);
    String totalCostStr = NumberFormat('#,###', 'vi_VN').format(order.totalCost) + 'đ';
    
    final bool isPast = departureDateTime.isBefore(DateTime.now());

    // Logic hiển thị theo trạng thái
    String statusText = '';
    Color statusColor = Colors.grey;
    bool isPending = false;
    bool showStamp = false;

    switch (order.orderStatus) {
      case 'HOLDING':
        statusText = 'Chờ thanh toán';
        statusColor = Colors.orange;
        isPending = true;
        break;
      case 'PAID':
        statusText = 'Đã thanh toán';
        statusColor = Colors.green;
        if (isPast) showStamp = true;
        break;
      case 'CANCELLED':
        statusText = 'Đã hủy';
        statusColor = Colors.red;
        break;
      case 'EXPIRED':
        statusText = 'Hết hạn';
        statusColor = Colors.red;
        break;
      default:
        statusText = order.orderStatus;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      statusText,
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      totalCostStr,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                          child: const Icon(Icons.directions_bus, color: Colors.blue, size: 24),
                        ),
                        const SizedBox(height: 8),
                        Text(timeStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(dateStr, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${order.departureProvince} → ${order.destinationProvince}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow('Nhà xe', order.busCompanyName),
                          const SizedBox(height: 4),
                          _buildInfoRow('Mã đơn hàng', order.orderId),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.blue),
                  ],
                ),
              ),
              // Nút bấm hành động
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: isPending ? Colors.red : const Color(0xFF0D47A1)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: isPending ? Colors.white : const Color(0xFF0D47A1),
                        ),
                        child: Text(
                          isPending ? 'Hủy đơn hàng' : 'Đặt lại',
                          style: TextStyle(
                            color: isPending ? Colors.red : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isPending ? const Color(0xFF1E88E5) : const Color(0xFFFFD54F),
                          foregroundColor: isPending ? Colors.white : Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        child: Text(
                          isPending ? 'Tiếp tục thanh toán' : 'Đặt chiều về',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Con dấu "ĐÃ ĐI" cho đơn hàng cũ
          if (showStamp)
            Positioned(
              right: 40,
              bottom: 80,
              child: Transform.rotate(
                angle: -math.pi / 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red.withOpacity(0.5), width: 2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'ĐÃ ĐI',
                    style: TextStyle(
                      color: Colors.red.withOpacity(0.5),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
