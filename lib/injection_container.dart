import 'package:get_it/get_it.dart';
import 'services/google_sheets_service.dart';
import 'services/multi_sheet_sync_service.dart';
import 'features/dashboard/domain/repositories/dashboard_repository.dart';
import 'features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'features/dashboard/domain/usecases/fetch_instructor_data_usecase.dart';
import 'features/dashboard/presentation/cubit/dashboard_cubit.dart';

final sl = GetIt.instance; // sl stands for Service Locator

Future<void> init() async {
  // 1. Features - Dashboard
  // Cubit
  sl.registerFactory(() => DashboardCubit(
    fetchInstructorDataUseCase: sl(),
    repository: sl(),
  ));

  // Use Cases
  sl.registerLazySingleton(() => FetchInstructorDataUseCase(sl()));

  // Repository
  sl.registerLazySingleton<DashboardRepository>(() => DashboardRepositoryImpl(
    sheetsService: sl(),
    multiSheetSyncService: sl(),
  ));

  // 2. Core / Services
  sl.registerLazySingleton(() => GoogleSheetsService());
  sl.registerLazySingleton(() => MultiSheetSyncService());
}
