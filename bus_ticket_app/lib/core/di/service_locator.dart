import 'package:get_it/get_it.dart';
import '../../data/services/api_service.dart';
import 'package:bus_ticket_app/data/repositories/AuthRepository.dart';
import 'package:bus_ticket_app/features/auth/viewmodels/auth_view_model.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Register API Service (Singleton - một instance duy nhất)
  getIt.registerLazySingleton<ApiService>(() => ApiService());

  // Register Repository (Singleton - phụ thuộc vào ApiService)
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(getIt<ApiService>()),
  );

  // Register ViewModel (Factory - tạo instance mới mỗi lần)
  getIt.registerFactory<AuthViewModel>(
    () => AuthViewModel(getIt<AuthRepository>()),
  );
}
