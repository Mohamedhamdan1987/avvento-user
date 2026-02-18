import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../../support/data/datasources/support_remote_datasource.dart';
import '../../../support/data/repositories/support_repository_impl.dart';
import '../../../support/domain/repositories/support_repository.dart';
import '../controllers/order_support_controller.dart';

class OrderSupportBinding extends Bindings {
  @override
  void dependencies() {
    final dioClient = DioClient.instance;
    final SupportRemoteDataSource remoteDataSource =
        SupportRemoteDataSourceImpl(dioClient);
    final SupportRepository supportRepository =
        SupportRepositoryImpl(remoteDataSource);

    final orderId = Get.arguments as String;

    Get.lazyPut<OrderSupportController>(
      () => OrderSupportController(
        supportRepository: supportRepository,
        orderId: orderId,
      ),
    );
  }
}
