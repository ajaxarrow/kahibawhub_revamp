import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kahibawhub_revamp/utils/ui_builter_utils.dart';
import '../layouts/circle_background.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../themes/colors.dart';
import '../widgets/custom_text_form_field.dart';
import '../providers/auth_provider.dart';
import 'complete_profile_screen.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _form = GlobalKey<FormState>();
  bool isRegister = true;
  bool showPassword = true;
  bool isLoading = false;
  bool isGoogleLoading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  void resetForm() {
    _form.currentState!.reset();
    _emailController.text = '';
    _firstNameController.text = '';
    _lastNameController.text = '';
    _passwordController.text = '';
  }

  void submit() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    // Replace the auth service code with this modified version

    _form.currentState!.save();
    final authService = ref.read(authServiceProvider);

    try {
      late AppUser user;
      if (isRegister) {
        user = await authService.register(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Save user to global state
        ref.read(userProvider.notifier).setUser(user);

        // Navigate to complete profile screen for new registrations
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => CompleteProfileScreen(
              isCompleting: true,
              userId: user.id,
            ),
          ),
        );
      } else {
        user = await authService.login(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Save user to global state
        ref.read(userProvider.notifier).setUser(user);

        // Navigate to dashboard for existing users
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } on DioException catch (e) {
      String action = isRegister ? 'Registration' : 'Login';
      String errorTitle = '$action Error';
      String errorMessage = '$action failed';

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        if (responseData is Map<String, dynamic> && responseData.containsKey('error')) {
          errorMessage = responseData['error'] ?? errorMessage;
        }

        print('$action failed (Status: $statusCode): $errorMessage');
      } else {
        errorMessage = '$action failed: Network error - ${e.message}';
        print(errorMessage);
      }

      showError(
        context: context,
        errorMessage: errorMessage,
        errorTitle: errorTitle,
      );

    }
    catch (error) {

      // Show error dialog
      showError(
          context: context,
          errorMessage: error.toString(),
          errorTitle: 'Error Occurred'
      );
    } finally {
      // Reset loading state if still mounted
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CircleBackground(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Form(
            key: _form,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 75),
                  Align(
                    alignment: Alignment.center,
                    child: Image.asset(
                      'lib/assets/images/placeholder-logo.png',
                      width: 75,
                      height: 75,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      isRegister ? "Create Your Account!" : "Welcome Back!",
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(height: 20),
                  isRegister ? CustomTextFormField(
                    label: 'First Name',
                    hintText: 'Enter your first name',
                    controller: _firstNameController, // Fixed: was using _emailController
                    prefixIcon: Icons.person_outline_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                  ) : const SizedBox.shrink(),
                  isRegister ? const SizedBox(height: 10) : const SizedBox.shrink(),
                  isRegister ? CustomTextFormField(
                    label: 'Last Name',
                    hintText: 'Enter your last name',
                    controller: _lastNameController,
                    prefixIcon: Icons.person_outline_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                  ) : const SizedBox.shrink(),
                  isRegister ? const SizedBox(height: 10) : const SizedBox.shrink(),
                  CustomTextFormField(
                    label: 'Username',
                    hintText: 'Enter your username',
                    controller: _emailController,
                    prefixIcon: Icons.person_outline_outlined,
                  ),
                  const SizedBox(height: 10),
                  CustomTextFormField(
                    label: 'Password',
                    hintText: 'Enter your password',
                    controller: _passwordController,
                    isPassword: true,
                    prefixIcon: Icons.lock_outline,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        disabledBackgroundColor: primaryColor.withOpacity(0.7),
                      ),
                      child: isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
                        ),
                      )
                          : Text(
                        isRegister ? "Register" : "Login",
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isRegister ? 'Already a User?' : 'New to KahibawHub?',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: isLoading
                            ? null
                            : () {
                          setState(() {
                            isRegister = !isRegister;
                          });
                        },
                        child: Text(
                          isRegister ? 'Login here!' : 'Register here!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                            color: isLoading ? Colors.grey : null,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}