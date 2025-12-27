import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../shared/widgets/common/loading_widget.dart';
import '../../../../shared/widgets/common/error_widget.dart';
import '../../../../shared/widgets/common/empty_widget.dart';
import '../logic/cubit/home_cubit.dart';
import '../logic/states/home_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<HomeCubit>()..loadHomeData(),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الرئيسية'),
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          return state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const LoadingWidget(message: 'جاري التحميل...'),
            loaded: (data) {
              if (data.isEmpty) {
                return const EmptyWidget(message: 'لا توجد بيانات');
              }
              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final item = data[index];
                  return ListTile(
                    title: Text(item.title),
                    subtitle: item.description != null
                        ? Text(item.description!)
                        : null,
                  );
                },
              );
            },
            error: (message) => CustomErrorWidget(
              message: message,
              onRetry: () {
                context.read<HomeCubit>().loadHomeData();
              },
            ),
          );
        },
      ),
    );
  }
}

