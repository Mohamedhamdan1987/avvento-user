import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<UserEntity> call({
    required String name,
    required String username,
    required String email,
    required String phone,
    required String password,
    String? address,
    double? lat,
    double? long,
  }) async {
    return await repository.register(
      name: name,
      username: username,
      email: email,
      phone: phone,
      password: password,
      address: address,
      lat: lat,
      long: long,
    );
  }
}

