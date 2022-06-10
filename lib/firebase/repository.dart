import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conqur_backend_test/utils/app_data.dart';
import 'package:conqur_backend_test/utils/emitter.dart';
import 'package:conqur_backend_test/utils/enum.dart';
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

  Future get currentUser async {
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

  Future get signout async {
    try {
      if (firebaseAuth.currentUser != null) {
        AppData().user = null;
        AppData().accessType = null;
        AppData().org_id = null;
        await firebaseAuth.signOut();
        return "Signed out successfully!";
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

  Future get accessType async {
    try {
      User? user = firebaseAuth.currentUser;
      if (user != null) {
        String uid = user.uid;

        DocumentSnapshot athlete =
            await firestore.collection(Collections.Athlete.id).doc(uid).get();
        DocumentSnapshot coach =
            await firestore.collection(Collections.Coach.id).doc(uid).get();

        if (athlete.exists) {
          AppData().accessType = AccessType.athlete;
          return "Athlete access";
        } else if (coach.exists) {
          AppData().accessType = AccessType.coach;
          return "Coach access";
        } else {
          Exceptionemitter.addException("User not authorized!");
          return;
        }
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

  Future get orgID async {
    try {
      User? user = firebaseAuth.currentUser;
      if (user != null) {
        String uid = user.uid;

        QuerySnapshot coachData = await firestore
            .collection(Collections.Ledger.id)
            .where("coach_id", isEqualTo: uid)
            .get();

        if (coachData.docs.length != 0) {
          AppData().org_id = coachData.docs[0]["organization_id"];
        } else {
          Exceptionemitter.addException("User not authorized!");
          return;
        }
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
    var acs = ActionCodeSettings(
        url: "http://localhost:58136/#/", handleCodeInApp: true);
    try {
      await firebaseAuth.sendPasswordResetEmail(
          email: email, actionCodeSettings: acs);
      return "Password reset link has been sent to your email";
    } on FirebaseAuthException catch (e) {
      Exceptionemitter.addException(e.toString());
      throw e.code;
    } catch (e) {
      throw e;
    }
  }

  Future get getCoachTeam async {
    try {
      checkAuth();

      if (AppData().accessType == AccessType.coach) {
        String uid = "c5hWOuo7hzRLNUyS8J6V";
        String org_id = "JXNWEpddCNXtC9bCznHb";

        QuerySnapshot coachTeamData = await firestore
            .collection(Collections.Ledger.id)
            .where('organization_id', isEqualTo: org_id)
            .where('coach_id', isEqualTo: uid)
            .get();

        CollectionReference teamData =
            await firestore.collection(Collections.Team.id);

        CollectionReference athleteData =
            await firestore.collection(Collections.Athlete.id);

        coachTeamData.docs.forEach((element) async {
          var team_name = await teamData
              .doc(element["team_id"])
              .get()
              .then((value) => value["name"]);

          var athlete_name = await athleteData
              .doc(element["athlete_id"])
              .get()
              .then((value) => value["first_name"]);

          print(
              "${element["team_id"]}/${team_name} -- ${element["athlete_id"]}/${athlete_name}");
        });
      } else {
        Exceptionemitter.addException(
            "You are not authorized to access this data");
      }
    } on FirebaseAuthException catch (e) {
      Exceptionemitter.addException(e.toString());
      throw e.code;
    } catch (e) {
      throw e;
    }
  }

  checkAuth() {
    if (AppData().user == null) {
      throw "User not logged in or Can't retrive user data";
    }
    if (AppData().accessType == null) {
      accessType;
    }
    if (AppData().org_id == null) {
      orgID;
    }
  }
}
