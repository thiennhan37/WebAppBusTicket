import 'package:bus_ticket_app/data/repositories/customer_repository.dart';
import 'package:bus_ticket_app/features/customer/viewmodels/profile_viewmodel.dart';
import 'package:bus_ticket_app/pages/account_info_pages.dart';
import 'package:bus_ticket_app/pages/login_page.dart';
import 'package:get_it/get_it.dart';
import 'package:bus_ticket_app/data/repositories/AuthRepository.dart';
import 'package:bus_ticket_app/features/auth/viewmodels/auth_view_model.dart';

import '../../data/services/auth_api_service.dart';
import '../../data/services/customer_api_service.dart';
import '../../data/services/storage_service.dart';
import '../network/api_client.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerLazySingleton<CustomerApiService>(
        () => CustomerApiService(getIt<ApiClient>()),
  );

  // 1. Đăng ký Core Services
  getIt.registerLazySingleton<StorageService>(() => StorageService());

  getIt.registerLazySingleton<ApiClient>(
        () => ApiClient(getIt<StorageService>()),
  );
  getIt.registerLazySingleton<CustomerRepository>(
        () => CustomerRepository(getIt<CustomerApiService>()),
  );
  getIt.registerLazySingleton<ProfileViewModel>(() => ProfileViewModel(getIt<CustomerRepository>()));

  // 2. Đăng ký Feature Data Sources
  getIt.registerLazySingleton<AuthApiService>(
        () => AuthApiService(getIt<ApiClient>()),
  );

  // 3. Đăng ký Repositories
  getIt.registerLazySingleton<AuthRepository>(
        () => AuthRepository(getIt<AuthApiService>()),
  );

  // 4. Đăng ký ViewModels
  getIt.registerFactory<AuthViewModel>(
        () => AuthViewModel(getIt<AuthRepository>()),
  );
}
