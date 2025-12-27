import '../../../../core/network/dio_client.dart';
import '../../../../core/error/exceptions.dart';
import '../models/home_model.dart';

class HomeRepo {
  final DioClient dioClient;

  HomeRepo(this.dioClient);

  Future<List<HomeModel>> getHomeData() async {
    try {
      final response = await dioClient.get('/home');
      
      if (response.data is List) {
        return (response.data as List)
            .map((json) => HomeModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['data'] is List) {
          return (data['data'] as List)
              .map((json) => HomeModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
      
      return [];
    } catch (e) {
      throw ServerException(message: 'حدث خطأ في جلب البيانات');
    }
  }
}

