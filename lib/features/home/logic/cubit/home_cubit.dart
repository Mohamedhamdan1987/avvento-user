import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/home_repo.dart';
import '../states/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepo homeRepo;

  HomeCubit(this.homeRepo) : super(const HomeState.initial());

  Future<void> loadHomeData() async {
    emit(const HomeState.loading());
    
    try {
      final data = await homeRepo.getHomeData();
      emit(HomeState.loaded(data));
    } catch (e) {
      emit(HomeState.error(e.toString()));
    }
  }
}

