import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/logic/cubit/auth_cubit.dart';
import 'features/auth/logic/states/auth_state.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/client/screens/client_home_screen.dart';
import 'core/utils/user_type.dart';
import 'features/driver/screens/driver_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Dependency Injection
  await setupDependencyInjection();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return BlocProvider(
          create: (context) => getIt<AuthCubit>(),
          child: MaterialApp(
            title: 'Avvento',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: const ClientHomeScreen(),
            routes: {
              '/login': (context) => const LoginScreen(),
            },
          ),
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return state.when(
          initial: () => const LoginScreen(),
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          authenticated: (user) {
            // Navigate based on user type
            if (user.userType == UserType.driver) {
              return const DriverHomeScreen();
            } else {
              return const ClientHomeScreen();
            }
          },
          unauthenticated: () => const LoginScreen(),
          error: (message) => const LoginScreen(),
        );
      },
    );
  }
}
