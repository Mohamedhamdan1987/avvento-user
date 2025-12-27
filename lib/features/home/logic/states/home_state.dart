// ignore_for_file: non_abstract_class_inherits_abstract_member
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/models/home_model.dart';

part 'home_state.freezed.dart';

@freezed
class HomeState with _$HomeState {
  const factory HomeState.initial() = _Initial;
  const factory HomeState.loading() = _Loading;
  const factory HomeState.loaded(List<HomeModel> data) = _Loaded;
  const factory HomeState.error(String message) = _Error;
}

