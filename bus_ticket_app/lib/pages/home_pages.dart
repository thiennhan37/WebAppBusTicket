import 'package:bus_ticket_app/widgets/bottom_navigation.dart';
import 'package:bus_ticket_app/widgets/home_pages_widgets/header.dart';
import 'package:bus_ticket_app/widgets/home_pages_widgets/recent_list.dart';
import 'package:bus_ticket_app/widgets/home_pages_widgets/service_tabs.dart';
import 'package:flutter/material.dart';
import 'package:bus_ticket_app/widgets/home_pages_widgets/search_card.dart';

class HomePages extends StatefulWidget {
  const HomePages({super.key});

  @override
  State<HomePages> createState() => _HomePagesState();
}

class _HomePagesState extends State<HomePages> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: const SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                HeaderHomePage(),
                Padding(
                  padding: EdgeInsets.only(top: 180, left: 16, right: 16),
                  child: SearchCard(),
                ),
              ],
            ),
            SizedBox(height: 24.0),
            ServiceTabs(),
            RecentList(),
          ],
        ),
      ),
    );
  }
}
