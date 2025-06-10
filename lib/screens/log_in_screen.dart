import 'package:flutter/material.dart';
import 'package:social_app/screens/Shared/custom_input_label_form.dart';
import 'package:social_app/screens/home_screen.dart';
import 'package:social_app/screens/log_in_screen.dart';
import 'package:social_app/screens/sign_up_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:social_app/services/app_service.dart';
import 'package:social_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_app/services/auth_service.dart';

class LogInScreen extends StatelessWidget {
  LogInScreen({super.key});
  final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 77, 10, 88),
            ),
          ),
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            // left:
            //     MediaQuery.of(context).size.width / 2 -
            //     'Welcome to My App'.length,
            child: Center(
              child: Text(
                'Welcome back',
                style: TextStyle(
                  color: Colors.white,
                  letterSpacing: 3,
                  fontSize: 24,
                ),
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Lottie.asset('assets/an1.json', width: 350, height: 350),
            ),
          ),
          Positioned.fill(
            top: 400,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 238, 236, 236),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 5,
                    blurRadius: 20,
                    offset: Offset(0, 5),
                  ),
                ],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(60.0),
                  topRight: Radius.circular(60.0),
                ),
              ),
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        CustomInputLabelForm(
                          hintText: 'Enter your email',
                          label: 'Email',
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'this field if required';
                            } else if (!emailRegExp.hasMatch(value)) {
                              return 'please enter a valid email';
                            }
                            return null;
                          },
                          controller: _emailController,
                          isPassword: false,
                        ),
                        SizedBox(height: 25),
                        CustomInputLabelForm(
                          hintText: 'Enter your password',
                          label: 'Password',
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'this field is required';
                            } else if (value.length < 6) {
                              return 'please enter at least 6 characters';
                            }
                            return null;
                          },
                          controller: _passwordController,
                          isPassword: true,
                        ),

                        SizedBox(height: 15),
                        Align(
                          alignment: Alignment.topLeft,
                          child: GestureDetector(
                            onTap: () async {
                              await AuthService().resetPassword(
                                _emailController.text,
                              );

                              // setState(() {
                              //   _feedbackMessage = result ?? "A password reset email has been sent.";
                              // });
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (BuildContext context) {
                              //       return ForgotPasswordScreen();
                              //     },
                              //   ),
                              // );
                            },
                            child: Text(
                              'Forget Password?',
                              style: TextStyle(
                                fontSize: 16,
                                letterSpacing: 2,
                                color: Color.fromARGB(255, 77, 10, 88),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 25),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => Center(
                                  child: CircularProgressIndicator(
                                    color: Color.fromARGB(255, 77, 10, 88),
                                  ),
                                ),
                              );
                              bool pop = false;
                              try {
                                final success = await AuthService().logInUser(
                                  email: _emailController.text,
                                  password: _passwordController.text,
                                );
                                if (success) {
                                  User? user =
                                      FirebaseAuth.instance.currentUser;

                                  if (user != null && !user.emailVerified) {
                                    pop = true;
                                    Navigator.of(
                                      context,
                                      rootNavigator: true,
                                    ).pop();
                                    AppService().show_dialog(
                                      context,
                                      user,
                                      user.emailVerified,
                                    ); // Remove loading
                                  } else if (user != null &&
                                      user.emailVerified == true) {
                                    pop = true;
                                    Navigator.of(
                                      context,
                                      rootNavigator: true,
                                    ).pop(); // Remove loading

                                    // Navigate to home
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HomeScreen(),
                                      ),
                                    );
                                  }
                                  // Show verification prompt

                                  // pop = true;
                                  // // Login succeeded
                                  // Navigator.of(
                                  //   context,
                                  //   rootNavigator: true,
                                  // ).pop(); // remove loading
                                  // Navigator.pushReplacement(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) => HomeScreen(),
                                  //   ),
                                  // );
                                }
                              } finally {
                                if (!pop) {
                                  Navigator.of(
                                    context,
                                    rootNavigator: true,
                                  ).pop();
                                  User? user =
                                      FirebaseAuth.instance.currentUser;
                                  if (user != null && user.emailVerified) {
                                    AppService().showToast(
                                      'User still not verified please try again',
                                    ); // Remove loading
                                  }
                                }
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: Color.fromARGB(255, 77, 10, 88),
                            foregroundColor: Color(0xFFFFFCFC),
                            textStyle: TextStyle(
                              fontSize: 22,
                              letterSpacing: 3,
                            ),
                            fixedSize: Size(400, 48),
                          ),
                          child: Text('Sign In'),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Don'
                              't have an account ?',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) {
                                      return SignUpScreen();
                                    },
                                  ),
                                );
                              },
                              child: Text('Sign Up'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
