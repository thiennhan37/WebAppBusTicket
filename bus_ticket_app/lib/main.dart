import 'dart:convert';

import 'package:bus_ticket_app/core/storage/storage_service.dart';
import 'package:bus_ticket_app/features/auth/viewmodels/auth_view_model.dart';
import 'package:bus_ticket_app/features/customer/viewmodels/favorite_viewmodel.dart';
import 'package:bus_ticket_app/features/notification/viewmodels/notification_view_model.dart';
import 'package:bus_ticket_app/pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'core/di/service_locator.dart';
import 'data/services/firebase_messaging_service.dart';
import 'global_varible.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  final prefs = await SharedPreferences.getInstance();
  final userInfoString = prefs.getString('user_info');
  if (userInfoString == null || userInfoString.isEmpty) {
    return;
  }

  dynamic decodedUserInfo;
  try {
    decodedUserInfo = jsonDecode(userInfoString);
  } catch (_) {
    return;
  }
  if (decodedUserInfo is! Map) {
    return;
  }

  final customerId = decodedUserInfo['id']?.toString() ?? decodedUserInfo['customerId']?.toString();
  if (customerId == null || customerId.isEmpty) {
    return;
  }

  final notificationJson = _notificationJsonFromRemoteMessage(message);
  final storageKey = 'notifications_$customerId';
  final currentString = prefs.getString(storageKey);
  dynamic currentDecoded = <dynamic>[];
  if (currentString != null && currentString.isNotEmpty) {
    try {
      currentDecoded = jsonDecode(currentString);
    } catch (_) {
      currentDecoded = <dynamic>[];
    }
  }
  final notifications = currentDecoded is List ? List<dynamic>.from(currentDecoded) : <dynamic>[];

  final eventId = notificationJson['eventId']?.toString();
  final alreadyExists = notifications.whereType<Map>().any((item) => item['eventId']?.toString() == eventId);
  if (alreadyExists) {
    return;
  }

  notifications.insert(0, notificationJson);
  await prefs.setString(storageKey, jsonEncode(notifications.take(100).toList()));
}

Map<String, dynamic> _notificationJsonFromRemoteMessage(RemoteMessage message) {
  final data = Map<String, dynamic>.from(message.data);
  final extraData = Map<String, dynamic>.from(data)
    ..remove('eventId')
    ..remove('type')
    ..remove('title')
    ..remove('message')
    ..remove('createdAt')
    ..remove('read');

  return {
    'eventId': data['eventId']?.toString() ?? message.messageId ?? DateTime.now().microsecondsSinceEpoch.toString(),
    'type': data['type']?.toString() ?? 'GENERAL',
    'title': data['title']?.toString() ?? message.notification?.title ?? 'Thông báo',
    'message': data['message']?.toString() ?? message.notification?.body ?? '',
    'createdAt': data['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
    'data': extraData,
    'read': false,
  };
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Khởi tạo định dạng ngày tháng cho tiếng Việt
  await initializeDateFormatting('vi_VN', null);

  setupServiceLocator();
  await getIt<StorageService>().init();
  await getIt<FirebaseMessagingService>().initialize();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthViewModel>(
        create: (_) => getIt<AuthViewModel>(),
      ),
      ChangeNotifierProvider<FavoriteViewModel>(
        create: (_) => getIt<FavoriteViewModel>(),
      ),
      ChangeNotifierProvider<NotificationViewModel>.value(
        value: getIt<NotificationViewModel>(),
      ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'VeXeDat',
      theme: ThemeData(
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
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
        useMaterial3: true,
      ),
      home: const SplashPage(),
    );
  }
}
