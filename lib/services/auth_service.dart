import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_app/services/app_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> registerUser({
    required String email,
    required String password,
    required displayName,
    required String image64,
  }) async {
    try {
      UserCredential userCredentialreg = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      if (!userCredentialreg.user!.emailVerified) {
        await userCredentialreg.user!.sendEmailVerification();
        AppService().showToast('Verification email sent');
      }
      await userCredentialreg.user!.updateDisplayName(displayName);

      await _firestore.collection('users').doc(userCredentialreg.user!.uid).set(
        {
          'uid': userCredentialreg.user!.uid,
          'email': email,
          'displayName': displayName,
          'imageUrl':
              image64 ?? "", // default empty string or a default image url
          'createdAt': FieldValue.serverTimestamp(),
        },
      );

      return userCredentialreg.user;
      // AppService().showToast('Registeration Successful');
    } catch (e) {
      AppService().showToast('Registeration failed: ${e.toString()}');
      return null;
    }
  }

  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      AppService().showToast('A password reset email has been sent.');
      return null; // Success, no error
    } on FirebaseAuthException catch (e) {
      AppService().showToast('Please enter  a valid email');

      return e.message;
    } catch (e) {
      AppService().showToast('An unexpected error occurred.');

      return "An unexpected error occurred.";
    }
  }

  Future<bool> logInUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential user1 = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      if (!user1.user!.emailVerified) {
        await user1.user!.sendEmailVerification();
        AppService().showToast('Verification email sent');
      }
      return user1 != null;
    } catch (e) {
      AppService().showToast('Login failed: please check email & password}');
      return false;
    }
  }

  Future<void> logOutUser() async {
    try {
      await FirebaseAuth.instance.signOut();
      AppService().showToast('Logout Successful');
    } catch (e) {
      AppService().showToast('Logout failed: ${e.toString()}');
    }
  }

  Future<User?> getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null)
      return user;
    else {
      AppService().showToast('No User is currently logged in');
      return null;
    }
  }

  Future<DocumentSnapshot?> getUserFromCollection() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String uid = currentUser.uid;

      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();

        if (userDoc.exists) {
          return userDoc;
        } else {
          print('User document does not exist');
          return null;
        }
      } catch (e) {
        print('Error getting user document: $e');
        return null;
      }
    } else {
      print('No user is logged in');
      return null;
    }
  }

  Future<bool> isEmailVerified() async {
    User? user = _auth.currentUser;
    await user?.reload();
    return user?.emailVerified ?? false;
  }

  Future<void> resendVerificationEmail() async {
    try {
      User? user = _auth.currentUser;
      print('in the resent function $user');
      if (user != null) {
        await user.reload(); // 🔁 Refresh latest state from Firebase

        if (!user.emailVerified) {
          await user.sendEmailVerification();
          AppService().showToast('Verification email resent');
        } else {
          AppService().showToast('Email already verified');
        }
      } else {
        AppService().showToast('No user is logged in');
      }
    } catch (e) {
      AppService().showToast('Error resending verification: ${e.toString()}');
    }
  }
}
