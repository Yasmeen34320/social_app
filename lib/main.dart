import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:social_app/firebase_options.dart';
import 'package:social_app/screens/home_screen.dart';
import 'package:social_app/screens/log_in_screen.dart';
import 'package:social_app/screens/sign_up_screen.dart';
import 'package:social_app/services/app_service.dart';
import 'package:social_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(), // 👈 Listen here
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 77, 10, 88),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error Loading User'));
          } else if (snapshot.hasData && snapshot.data != null) {
            User user = snapshot.data!;

            // Reload to ensure latest email verification state
            return FutureBuilder(
              future: user.reload(),
              builder: (context, reloadSnapshot) {
                if (reloadSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color.fromARGB(255, 77, 10, 88),
                    ),
                  );
                }

                if (user.emailVerified) {
                  return HomeScreen();
                }
                // } else {
                //   AppService().showToast(
                //     'The email not verified please try again',
                //   );
                return LogInScreen(); // Or a custom "Verify your email" screen
              },
            );

            // return const HomeScreen();
          } else {
            return LogInScreen();
          }
        },
      ),

      //  FutureBuilder(
      //   builder: (context, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return Center(
      //         child: CircularProgressIndicator(
      //           color: Color.fromARGB(255, 77, 10, 88),
      //         ),
      //       );
      //     } else if (snapshot.hasError) {
      //       return Center(child: Text('Error Loading User'));
      //     } else if (snapshot.hasData && snapshot.data != null) {
      //       return HomeScreen();
      //     } else {
      //       return LogInScreen();
      //     }
      //   },
      //   future: AuthService().getCurrentUser(),
      // ),
    );
  }
}
