import 'package:bus_ticket_app/core/storage/storage_service.dart';
import 'package:bus_ticket_app/features/auth/viewmodels/auth_view_model.dart';
import 'package:bus_ticket_app/features/customer/viewmodels/favorite_viewmodel.dart';
import 'package:bus_ticket_app/pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'core/di/service_locator.dart';
import 'global_varible.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo định dạng ngày tháng cho tiếng Việt
  await initializeDateFormatting('vi_VN', null);

  setupServiceLocator();
  await getIt<StorageService>().init();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthViewModel>(
        create: (_) => getIt<AuthViewModel>(),
      ),
      ChangeNotifierProvider<FavoriteViewModel>(
        create: (_) => getIt<FavoriteViewModel>(),
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
