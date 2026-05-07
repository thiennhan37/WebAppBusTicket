import 'package:bus_ticket_app/data/repositories/customer_repository.dart';
import 'package:bus_ticket_app/data/repositories/location_repository.dart';
import 'package:bus_ticket_app/data/services/location_api_service.dart';
import 'package:bus_ticket_app/features/booking/viewmodel/location_viewmodel.dart';
import 'package:bus_ticket_app/features/booking/viewmodel/search_trip_viewmodel.dart';
import 'package:bus_ticket_app/features/booking/viewmodel/search_trip_viewmodel.dart';
import 'package:bus_ticket_app/features/customer/viewmodels/profile_viewmodel.dart';
import 'package:get_it/get_it.dart';
import 'package:bus_ticket_app/data/repositories/AuthRepository.dart';
import 'package:bus_ticket_app/features/auth/viewmodels/auth_view_model.dart';

import '../../data/repositories/trip_repository.dart';
import '../../data/services/auth_api_service.dart';
import '../../data/services/customer_api_service.dart';
import '../../data/services/local/auth_storage.dart';
import '../../data/services/local/booking_storage.dart';
import '../../data/services/trip_api_service.dart';
import '../storage/storage_service.dart';
import '../network/api_client.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerLazySingleton<TripApiService>(
        () => TripApiService(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<TripRepository>(
        () => TripRepository(getIt<TripApiService>()),
  );

  getIt.registerFactory<SearchTripViewModel>(
        () => SearchTripViewModel(getIt<TripRepository>()),
  );

  getIt.registerLazySingleton<CustomerApiService>(
        () => CustomerApiService(getIt<ApiClient>()),
  );

  //Cho Location
  getIt.registerLazySingleton<LocationApiService>(
        () => LocationApiService(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<LocationRepository>(
        () => LocationRepository(getIt<LocationApiService>()),
  );

  getIt.registerFactory<LocationViewModel>(
        () => LocationViewModel(getIt<LocationRepository>()),
  );


  // 1. Đăng ký Core Services
  getIt.registerLazySingleton<StorageService>(() => StorageService());
  getIt.registerLazySingleton<AuthStorage>(() => AuthStorage(getIt<StorageService>()));
  getIt.registerLazySingleton<BookingStorage>(() => BookingStorage(getIt<StorageService>()));

  getIt.registerLazySingleton<ApiClient>(
        () => ApiClient(getIt<AuthStorage>()),
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
        () => AuthViewModel(getIt<AuthRepository>(), getIt<ApiClient>()),
  );
}
