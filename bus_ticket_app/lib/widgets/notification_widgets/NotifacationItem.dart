import 'package:flutter/material.dart';

class NotificationItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final String title;
  final String content;
  final String time;
  final bool read;
  final VoidCallback? onTap;

  const NotificationItem({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.title,
    required this.content,
    required this.time,
    this.read = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        // Khi đã đọc (read == true) thì chuyển sang màu sẫm (xám nhạt)
        // Khi chưa đọc thì để màu trắng
        color: read ? const Color(0xFFF2F2F2) : Colors.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Khung chứa Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: read ? Colors.grey.shade300 : iconBackgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: read ? Colors.grey.shade600 : iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),

            // Phần nội dung (Title, Content, Time)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: read ? FontWeight.w500 : FontWeight.bold,
                      color: read ? Colors.black54 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 14,
                      color: read ? Colors.black45 : Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 12,
                      color: read ? Colors.grey.shade500 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
