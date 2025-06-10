import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:social_app/screens/home_screen.dart';
import 'package:social_app/screens/log_in_screen.dart';
import 'package:social_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppService {
  showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 15,
      backgroundColor: Color.fromARGB(255, 77, 10, 88),
      textColor: Colors.white,
      fontSize: 18.0,
    );
  }

  Future<dynamic> show_dialog(
    BuildContext context,
    User user,
    bool isVerified,
  ) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Email Verification'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Please verify your email to continue.'),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        // User? currentUser = FirebaseAuth.instance.currentUser;
                        await FirebaseAuth.instance.currentUser?.reload();
                        User? currentUser = FirebaseAuth.instance.currentUser;

                        await currentUser?.sendEmailVerification();
                        AppService().showToast('Verification email sent');
                      } catch (e) {
                        Navigator.of(context).pop();
                        print(e.toString());
                        AppService().showToast(
                          'Error occured please try again ${e.toString()}',
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LogInScreen(),
                          ),
                        );
                      }
                    },
                    child: Text('Resend Verification Email'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text('I have verified'),
                  onPressed: () async {
                    await FirebaseAuth.instance.currentUser?.reload();
                    User? refreshedUser = FirebaseAuth.instance.currentUser;

                    // isVerified = refreshedUser?.emailVerified!;
                    print(refreshedUser);
                    if (refreshedUser != null && refreshedUser.emailVerified) {
                      Navigator.of(context).pop();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    } else {
                      AppService().showToast('Email not verified yet.');
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
