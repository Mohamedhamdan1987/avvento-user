import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Data sources
    final dioClient = DioClient();
    final localDataSource = AuthLocalDataSourceImpl(GetStorage());
    final remoteDataSource = AuthRemoteDataSourceImpl(dioClient);

    // Repository
    final authRepository = AuthRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
    );

    // Use cases
    final loginUseCase = LoginUseCase(authRepository);
    final registerUseCase = RegisterUseCase(authRepository);

    // Controller
    Get.lazyPut<AuthController>(
      () => AuthController(
        loginUseCase: loginUseCase,
        registerUseCase: registerUseCase,
        authRepository: authRepository,
        storage: GetStorage(),
      ),
    );
  }
}

