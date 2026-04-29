import 'package:flutter/material.dart';

class EmptyTicketWidget extends StatelessWidget {
  const EmptyTicketWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF90CAF9),
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Center(
                child: Icon(
                  Icons.directions_bus,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Bạn chưa có đơn hàng nào',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Hãy thử kéo xuống để cập nhật danh sách đơn hàng trong 3 tháng gần đây',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.4,
              ),
            ),

            // Đẩy layout lên một chút để icon nằm ở vị trí trung tâm mắt nhìn
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
