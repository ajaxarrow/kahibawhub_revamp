import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kahibawhub_revamp/utils/ui_helpers.dart';
import '../layouts/circle_background.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../themes/colors.dart';
import '../widgets/custom_text_form_field.dart';
import '../providers/auth_provider.dart';

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
      } else {
        user = await authService.login(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }

      // Save user to global state
      ref.read(userProvider.notifier).setUser(user);

      // Navigate to dashboard or redirect screen
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } catch (error) {
      showError(context: context, errorMessage: error.toString(), errorTitle: 'Authentication Error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication failed: ${error.toString()}')),
      );
    } finally {
      // If navigation doesn't happen (due to error), reset loading state
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
                    label: 'Email',
                    hintText: 'Enter your email',
                    controller: _emailController,
                    prefixIcon: Icons.email_outlined,
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