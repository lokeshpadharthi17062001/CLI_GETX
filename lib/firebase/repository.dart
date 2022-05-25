import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseRepository {
  static final FirebaseRepository _firebaserepository =
      FirebaseRepository._internal();

  factory FirebaseRepository() {
    return _firebaserepository;
  }

  FirebaseRepository._internal();

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future signUp(String email, String password) async {
    try {
      final user = await firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      await user.user?.sendEmailVerification();
      return user;
    } catch (e) {
      print(e);
    }
  }

  Future signIn(String email, String password) async {
    try {
      final user = await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      if (user.user!.emailVerified) {
        throw "pending email verification!";
      }
      return user;
    } catch (e) {
      print(e);
    }
  }
}
