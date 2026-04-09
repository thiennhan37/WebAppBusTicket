import 'package:bus_ticket_app/widgets/my_ticket_widgets/EmptyTicketWidget.dart';
import 'package:bus_ticket_app/widgets/my_ticket_widgets/EmptyTicketWidget.dart';
import 'package:bus_ticket_app/widgets/my_ticket_widgets/EmptyTicketWidget.dart';
import 'package:flutter/material.dart';

class MyTicketsPages extends StatelessWidget {
  const MyTicketsPages({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          elevation: 0,
          title: const Text(
            'Vé của tôi',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
              label: const Text(
                'Làm mới',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              color: Colors.white,
              child: const TabBar(
                indicatorColor: Color(0xFF1E88E5),
                indicatorWeight: 3,
                labelColor: Colors.black87,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                unselectedLabelColor: Colors.grey,
                unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 15,
                ),
                tabs: [
                  Tab(text: 'Hiện tại'),
                  Tab(text: 'Đã đi'),
                  Tab(text: 'Đã hủy'),
                ],
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  // Tab 1: Hiện tại (Trong thực tế bạn sẽ bọc bằng RefreshIndicator)
                  EmptyTicketWidget(),

                  // Tab 2: Đã đi
                  EmptyTicketWidget(),

                  // Tab 3: Đã hủy
                  EmptyTicketWidget(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
