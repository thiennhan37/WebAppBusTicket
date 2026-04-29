import 'package:flutter/material.dart';

class FavoritePages extends StatelessWidget {
  const FavoritePages({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Nền xám nhạt
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Yêu thích',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite,
                color: Colors.blue.shade200, // Màu xanh nhạt theo thiết kế
                size: 100,
              ),
              const SizedBox(height: 8),

              Container(
                width: 50,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(
                    50,
                  ), // Bo tròn thành hình oval
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                'Bạn chưa lưu chuyến xe nào',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              const Text(
                'Nhấn vào biểu tượng trái tim trên chuyến xe\nđể lưu và đặt lại trong tích tắc',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 60), // Đẩy layout lên một chút cho cân đối
            ],
          ),
        ),
      ),
    );
  }
}
