import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conqur_backend_test/utils/app_data.dart';
import 'package:conqur_backend_test/utils/emitter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseRepository {
  static final FirebaseRepository _firebaserepository =
      FirebaseRepository._internal();

  factory FirebaseRepository() {
    return _firebaserepository;
  }

  FirebaseRepository._internal();

  Emitter Exceptionemitter = Emitter();

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future signUp(String email, String password) async {
    try {
      late UserCredential user;
      await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((userData) {
        userData.user?.sendEmailVerification();
        user = userData;
        AppData().user = user;
      });
      return user;
    } on FirebaseAuthException catch (e) {
      Exceptionemitter.addException(e.toString());
      throw e.code;
    } catch (e) {
      throw e;
    }
  }

  Future signIn(String email, String password) async {
    try {
      UserCredential user = await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      if (!user.user!.emailVerified) {
        user.user?.sendEmailVerification();
        Exceptionemitter.addException(
            "Pending email verification...\nIf you cant find verification link in your inbox please do check your SPAM folder once");
        return;
      }
      AppData().user = user;
      return user;
    } on FirebaseAuthException catch (e) {
      Exceptionemitter.addException(e.toString());
      throw e.code;
    } catch (e) {
      throw e;
    }
  }

  Future get CurrentUser async {
    try {
      if (firebaseAuth.currentUser != null) {
        return firebaseAuth.currentUser;
      }
      Exceptionemitter.addException(
          "User not logged in or Can't retrive user data");
    } on FirebaseAuthException catch (e) {
      Exceptionemitter.addException(e.toString());
      throw e.code;
    } catch (e) {
      throw e;
    }
  }

  Future updatePassword(String password) async {
    try {
      if (firebaseAuth.currentUser != null) {
        await firebaseAuth.currentUser?.updatePassword(password);
        return "Password updated successfully!";
      }
      Exceptionemitter.addException(
          "User not logged in or Can't retrive user data");
    } on FirebaseAuthException catch (e) {
      Exceptionemitter.addException(e.toString());
      throw e.code;
    } catch (e) {
      throw e;
    }
  }

  Future resetPasswordLink(String email) async {
    var acs = ActionCodeSettings(url: "http://localhost:58136/#/", handleCodeInApp: true);
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email, actionCodeSettings: acs);
      return "Password reset link has been sent to your email";
    } on FirebaseAuthException catch (e) {
      Exceptionemitter.addException(e.toString());
      throw e.code;
    } catch (e) {
      throw e;
    }
  }

  // Future resetPassword(String code, String password) async {
  //   try {
  //     await firebaseAuth.confirmPasswordReset(
  //         code: code, newPassword: password);
  //     return "Password updated successfully!";
  //   } on FirebaseAuthException catch (e) {
  //     Exceptionemitter.addException(e.toString());
  //     throw e.code;
  //   } catch (e) {
  //     throw e;
  //   }
  // }
}
