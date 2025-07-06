import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../layouts/circle_background.dart';
import '../themes/colors.dart';
import '../widgets/custom_text_form_field.dart'; // Import phosphor icons

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
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
    // AuthUser user = AuthUser(
    //   name: _usernameController.text,
    //   password: _passwordController.text,
    //   email: _emailController.text,
    //   context: context,
    // );

    try {
      if (isRegister) {
        // await user.register();
      } else {
        // await user.login();
      }
      Navigator.of(context).pushReplacementNamed('/redirect');
    } catch (error) {
      // Handle any errors that might occur during login/register
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
                    controller: _emailController,
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
                  const SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // Set border radius here
                        ),
                        // Button will be disabled when isLoading is true
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
                  // Row(
                  //   children: [
                  //     Expanded(child: Divider(color: Colors.grey.shade400)),
                  //     Padding(
                  //       padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  //       child: Text(
                  //         "OR",
                  //         style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                  //       ),
                  //     ),
                  //     Expanded(child: Divider(color: Colors.grey.shade400)),
                  //   ],
                  // ),

                  // const SizedBox(height: 20),
                  //
                  // // Google Sign-In Button
                  // SizedBox(
                  //   width: double.infinity,
                  //   child: ElevatedButton.icon(
                  //     onPressed: isGoogleLoading ? null : signInWithGoogle,
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: Colors.white,
                  //       foregroundColor: Colors.black87,
                  //       padding: const EdgeInsets.symmetric(vertical: 12),
                  //       elevation: 1,
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(10),
                  //         side: BorderSide(color: Colors.grey.shade300),
                  //       ),
                  //     ),
                  //     icon: isGoogleLoading
                  //         ? const SizedBox(
                  //       height: 20,
                  //       width: 20,
                  //       child: CircularProgressIndicator(
                  //         strokeWidth: 3,
                  //         color: primaryColor,
                  //       ),
                  //     )
                  //         :  Icon(
                  //       PhosphorIcons.googleLogo(),
                  //       size: 20,
                  //       color: Colors.red,
                  //     ),
                  //     label: Text(
                  //       isRegister ? "Register with Google" : "Login with Google",
                  //       style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  //     ),
                  //   ),
                  // ),

                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isRegister ? 'Already a User?' : 'New to KahibawHub?',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
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