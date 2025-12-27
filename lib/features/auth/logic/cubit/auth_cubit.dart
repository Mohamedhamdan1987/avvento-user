import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/user_type.dart';
import '../../data/repo/auth_repo.dart';
import '../states/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo authRepo;

  AuthCubit(this.authRepo) : super(const AuthState.unauthenticated());

  Future<void> login(String email, String password) async {
    emit(const AuthState.loading());
    
    try {
      final user = await authRepo.login(email, password);
      emit(AuthState.authenticated(user));
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    required UserType userType,
  }) async {
    emit(const AuthState.loading());
    
    try {
      final user = await authRepo.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        userType: userType,
      );
      emit(AuthState.authenticated(user));
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  void logout() {
    authRepo.logout();
    emit(const AuthState.unauthenticated());
  }
}

