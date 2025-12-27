import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/user_type.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/custom_text_field.dart';
import '../../../../shared/widgets/common/loading_widget.dart';
import '../logic/cubit/auth_cubit.dart';
import '../logic/states/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  UserType _selectedUserType = UserType.client;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().register(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            phone: _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
            userType: _selectedUserType,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التسجيل'),
      ),
      body: BlocProvider(
        create: (context) => getIt<AuthCubit>(),
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            state.whenOrNull(
              error: (message) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(message)),
                );
              },
              authenticated: (user) {
                Navigator.of(context).pushReplacementNamed('/');
              },
            );
          },
          builder: (context, state) {
            return state.when(
              initial: () => _buildRegisterForm(),
              loading: () => const LoadingWidget(message: 'جاري التسجيل...'),
              authenticated: (user) => const SizedBox.shrink(),
              unauthenticated: () => _buildRegisterForm(),
              error: (message) => _buildRegisterForm(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRegisterForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            // User Type Selection
            const Text(
              'نوع المستخدم',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<UserType>(
                    title: const Text('عميل'),
                    value: UserType.client,
                    groupValue: _selectedUserType,
                    onChanged: (value) {
                      setState(() {
                        _selectedUserType = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<UserType>(
                    title: const Text('سائق'),
                    value: UserType.driver,
                    groupValue: _selectedUserType,
                    onChanged: (value) {
                      setState(() {
                        _selectedUserType = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'الاسم',
              hint: 'أدخل اسمك',
              controller: _nameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الاسم مطلوب';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'البريد الإلكتروني',
              hint: 'أدخل بريدك الإلكتروني',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'البريد الإلكتروني مطلوب';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'رقم الهاتف (اختياري)',
              hint: 'أدخل رقم هاتفك',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'كلمة المرور',
              hint: 'أدخل كلمة المرور',
              controller: _passwordController,
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'كلمة المرور مطلوبة';
                }
                if (value.length < 6) {
                  return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'تأكيد كلمة المرور',
              hint: 'أعد إدخال كلمة المرور',
              controller: _confirmPasswordController,
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'تأكيد كلمة المرور مطلوب';
                }
                if (value != _passwordController.text) {
                  return 'كلمة المرور غير متطابقة';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'تسجيل',
              onPressed: _handleRegister,
            ),
          ],
        ),
      ),
    );
  }
}
