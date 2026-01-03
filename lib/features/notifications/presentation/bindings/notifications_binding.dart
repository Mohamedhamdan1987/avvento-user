import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/notifications_remote_datasource.dart';
import '../../data/repositories/notifications_repository_impl.dart';
import '../controllers/notifications_controller.dart';

class NotificationsBinding extends Bindings {
  @override
  void dependencies() {
    // Create DioClient instance
    final dioClient = DioClient();
    final remoteDataSource = NotificationsRemoteDataSourceImpl(dioClient);
    final repository = NotificationsRepositoryImpl(remoteDataSource);
    Get.lazyPut<NotificationsController>(
      () => NotificationsController(repository),
    );
  }
}
