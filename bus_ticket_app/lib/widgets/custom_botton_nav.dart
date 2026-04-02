import 'package:flutter/material.dart';

class CustomBottonNav extends StatefulWidget {
  const CustomBottonNav({super.key});

  @override
  State<CustomBottonNav> createState() => _CustomBottonNavState();
}

class _CustomBottonNavState extends State<CustomBottonNav> {
  int _selectedItem = 0;
  void _onItemTapped(int index){
    setState(() {
      _selectedItem = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: _selectedItem,
      onDestinationSelected: _onItemTapped,
      backgroundColor: Colors.white,
      indicatorColor: Theme.of(context).colorScheme.primary,
      surfaceTintColor: Colors.transparent,

      destinations: const [
        NavigationDestination(icon: Icon(Icons.search_outlined), label: 'Tìm kiếm'),
        NavigationDestination(icon: Icon(Icons.confirmation_num_outlined), label: 'Vé của tôi'),
        NavigationDestination(icon: Icon(Icons.favorite_outline), label: 'Yêu thích'),
        NavigationDestination(icon: Icon(Icons.notifications_none), label: 'Thông báo'),
        NavigationDestination(icon: Icon(Icons.person_outline), label: 'Tài khoản'),
      ],
    );
  }
}
