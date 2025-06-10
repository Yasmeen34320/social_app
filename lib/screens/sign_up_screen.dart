import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:social_app/screens/Shared/custom_input_label_form.dart';
import 'package:social_app/screens/home_screen.dart';
import 'package:social_app/screens/log_in_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:social_app/services/app_service.dart';
import 'package:social_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});
  final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  File? selectedImage;
  String? base64Image;
  @override
  Widget build(BuildContext context) {
    Future<void> pickAndConvertImage() async {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        selectedImage = File(pickedFile.path);
        final bytes = await selectedImage!.readAsBytes();
        base64Image = base64Encode(bytes);
        // setState(() {});
      }
    }

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
            top: 60,
            left: 0,
            right: 0,
            // left:
            //     MediaQuery.of(context).size.width / 2 -
            //     'Welcome to My App'.length,
            child: Center(
              child: Text(
                'Welcome to Our App',
                style: TextStyle(
                  color: Colors.white,
                  letterSpacing: 3,
                  fontSize: 24,
                ),
              ),
            ),
          ),
          Positioned(
            top: 70,
            left: 0,
            right: 0,
            child: Center(
              child: Lottie.asset('assets/an1.json', width: 350, height: 250),
            ),
          ),
          Positioned.fill(
            top: 310,
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
                        Center(
                          child: GestureDetector(
                            onTap: pickAndConvertImage,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: (selectedImage == null)
                                  ? AssetImage('assets/pp.png')
                                  : MemoryImage(base64Decode(base64Image!)),
                            ),
                          ),
                        ),
                        SizedBox(height: 25),
                        CustomInputLabelForm(
                          hintText: 'Enter your username',
                          label: 'username',
                          validator: (String? value) {
                            return null;
                          },
                          controller: _usernameController,
                          isPassword: false,
                        ),
                        SizedBox(height: 25),

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
                        SizedBox(height: 25),

                        ElevatedButton(
                          onPressed: () async {
                            if ((_formKey.currentState?.validate() ?? false)) {
                              // Show loading indicator
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
                                User? user = await AuthService().registerUser(
                                  email: _emailController.text,
                                  password: _passwordController.text,
                                  displayName: _usernameController.text,
                                  image64: base64Image ?? "",
                                );
                                pop = true;
                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).pop();

                                if (user != null) {
                                  // Start polling for verification
                                  bool isVerified = false;
                                  AppService().show_dialog(
                                    context,
                                    user,
                                    isVerified,
                                  );
                                }

                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (_) => EmailVerificationScreen(),
                                //   ),
                                // );
                              } finally {
                                if (!pop) {
                                  Navigator.of(
                                    context,
                                    rootNavigator: true,
                                  ).pop(); // Remove loading
                                }
                              }

                              // Navigator.pushReplacement(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (BuildContext context) {
                              //       return LogInScreen();
                              //     },
                              //   ),
                              // );
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
                          child: Text('Sign Up'),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'have an account ?',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) {
                                      return LogInScreen();
                                    },
                                  ),
                                );
                              },
                              child: Text('Sign In'),
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
