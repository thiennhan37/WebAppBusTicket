import 'package:flutter/material.dart';

import '../pages/account_info_pages.dart';
import '../pages/favorite_pages.dart';
import '../pages/home_pages.dart';
import '../pages/my_tickets_pages.dart';
import '../pages/notification_pages.dart';

class CustomBottonNav extends StatefulWidget {
  const CustomBottonNav({super.key});

  @override
  State<CustomBottonNav> createState() => CustomBottonNavState();
}

class CustomBottonNavState extends State<CustomBottonNav> {
  int _selectedItem = 0;

  final List<Widget> _pages = [
    const HomePages(),
    const MyTicketsPages(),
    const FavoritePages(),
    const NotificationPages(),
    const AccountInfoPages(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedItem = index;
    });
  }

  void changeTab(int index) {
    setState(() {
      _selectedItem = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedItem],

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedItem,
        onDestinationSelected: _onItemTapped,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFE3F2FD),
        surfaceTintColor: Colors.transparent,

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search, color: Color(0xFF1E88E5)),
            label: 'Tìm kiếm',
          ),
          NavigationDestination(
            icon: Icon(Icons.confirmation_num_outlined),
            selectedIcon: Icon(
              Icons.confirmation_num,
              color: Color(0xFF1E88E5),
            ),
            label: 'Vé của tôi',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite, color: Color(0xFF1E88E5)),
            label: 'Yêu thích',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_none),
            selectedIcon: Icon(Icons.notifications, color: Color(0xFF1E88E5)),
            label: 'Thông báo',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Color(0xFF1E88E5)),
            label: 'Tài khoản',
          ),
        ],
      ),
    );
  }
}
