import 'package:get_it/get_it.dart';
import '../network/dio_client.dart';
import '../../features/auth/data/repo/auth_repo.dart';
import '../../features/auth/logic/cubit/auth_cubit.dart';
import '../../features/home/data/repo/home_repo.dart';
import '../../features/home/logic/cubit/home_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // External
  _setupExternal();

  // Core
  _setupCore();

  // Features
  _setupAuthFeature();
  _setupHomeFeature();
}

void _setupAuthFeature() {
  // Repository
  getIt.registerLazySingleton<AuthRepo>(
    () => AuthRepo(getIt<DioClient>()),
  );

  // Cubit
  getIt.registerFactory(
    () => AuthCubit(getIt<AuthRepo>()),
  );
}

void _setupHomeFeature() {
  // Repository
  getIt.registerLazySingleton<HomeRepo>(
    () => HomeRepo(getIt<DioClient>()),
  );

  // Cubit
  getIt.registerFactory(
    () => HomeCubit(getIt<HomeRepo>()),
  );
}

void _setupExternal() {
  // يمكن إضافة external services هنا مثل SharedPreferences, etc.
}

void _setupCore() {
  // Dio Client
  getIt.registerLazySingleton<DioClient>(
    () => DioClient(
      // يمكن تمرير getToken function هنا إذا كان موجوداً
      // getToken: () => getIt<AuthService>().getToken(),
    ),
  );
}

