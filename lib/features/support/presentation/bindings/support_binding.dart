import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/support_remote_datasource.dart';
import '../../data/repositories/support_repository_impl.dart';
import '../../domain/repositories/support_repository.dart';
import '../controllers/support_controller.dart';

class SupportBinding extends Bindings {
  @override
  void dependencies() {
    final dioClient = DioClient.instance;
    final SupportRemoteDataSource remoteDataSource = SupportRemoteDataSourceImpl(dioClient);
    final SupportRepository supportRepository = SupportRepositoryImpl(remoteDataSource);
    Get.lazyPut<SupportController>(
      () => SupportController(supportRepository: supportRepository),
    );
  }
}

