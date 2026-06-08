import 'package:bus_ticket_app/pages/order_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/notification/viewmodels/notification_view_model.dart';
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
        title: const Text(
          'Thông báo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Consumer<NotificationViewModel>(
            builder: (context, viewModel, _) => TextButton(
              onPressed: viewModel.notifications.isEmpty ? null : viewModel.markAllAsRead,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Đánh dấu đã đọc',
                    style: TextStyle(
                      fontSize: 14,
                      color: viewModel.notifications.isEmpty ? Colors.white70 : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Container(height: 2, width: 100, color: Colors.white),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
      body: Consumer<NotificationViewModel>(
        builder: (context, viewModel, _) => _buildNotificationList(viewModel, context),
      ),
    );
  }

  Widget _buildNotificationList(NotificationViewModel viewModel, BuildContext context) {
    final notifications = viewModel.notifications;
    if (notifications.isEmpty) {
      return const Center(
        child: Text(
          'Chưa có thông báo',
          style: TextStyle(color: Colors.black54, fontSize: 15),
        ),
      );
    }

    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return Column(
          children: [
            NotificationItem(
              icon: notification.icon,
              iconColor: notification.iconColor,
              iconBackgroundColor: notification.iconBackgroundColor,
              title: notification.title,
              content: notification.message,
              time: notification.displayTime,
              read: notification.read,
              onTap: () {
                viewModel.markAsRead(notification.eventId);
                
                final orderId = notification.data['orderId'] ?? notification.data['bookingOrderId'];
                if (orderId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderDetailPage(orderId: orderId.toString()),
                    ),
                  );
                }
              },
            ),
            if (index < notifications.length - 1) _buildDivider(),
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
