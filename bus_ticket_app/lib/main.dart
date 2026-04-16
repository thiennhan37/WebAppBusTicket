import 'package:bus_ticket_app/pages/account_info_pages.dart';
import 'package:bus_ticket_app/pages/favorite_pages.dart';
import 'package:bus_ticket_app/pages/home_pages.dart';
import 'package:bus_ticket_app/pages/login_page.dart';
import 'package:bus_ticket_app/pages/my_tickets_pages.dart';
import 'package:bus_ticket_app/pages/notification_pages.dart';
import 'package:bus_ticket_app/widgets/bottom_navigation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VeXeDat',
      theme: ThemeData(
        fontFamily: 'Lato',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          primary: const Color(0xFF1E88E5),
        ),
        appBarTheme: const AppBarTheme(
          toolbarTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        textTheme: TextTheme(),
        useMaterial3: true,
      ),
      // home: CustomBottonNav(),
      home: LoginPage(),
    );
  }
}
