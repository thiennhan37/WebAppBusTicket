import 'package:flutter/material.dart';
import '../global_varible.dart';
import '../widgets/notification_widgets/NotifacationItem.dart';

class NotificationPages extends StatelessWidget {
  const NotificationPages({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Thông báo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Đánh dấu đã đọc',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2.0),
                Container(height: 2, width: 100, color: Colors.white),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
      body: _buildNotificationList(),
    );
  }

  Widget _buildNotificationList() {
    return ListView.builder(
      itemCount: mockNotifications.length,
      itemBuilder: (context, index) {
        final notification = mockNotifications[index];
        return Column(
          children: [
            NotificationItem(
              icon: notification['icon'],
              iconColor: notification['iconColor'],
              iconBackgroundColor: notification['iconBackgroundColor'],
              title: notification['title'],
              content: notification['content'],
              time: notification['time'],
            ),
            // Vẽ đường phân cách (trừ phần tử cuối cùng để giao diện sạch hơn)
            if (index < notification.length) _buildDivider(),
          ],
        );
      },
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.shade200,
      indent: 16,
      endIndent: 16,
    );
  }
}
