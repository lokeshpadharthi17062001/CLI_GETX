import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:conqur_backend_test/utils/app_data.dart';
import 'package:conqur_backend_test/utils/emitter.dart';
import 'package:conqur_backend_test/utils/enum.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

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
  FirebaseFunctions functions = FirebaseFunctions.instance;

  Future signUp(String email, String password) async {
    try {
      late UserCredential user;
      await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((userData) {
        userData.user?.sendEmailVerification();
        user = userData;
        AppData().user = user.user;
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
      AppData().user = user.user;
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
        AppData().user = firebaseAuth.currentUser;
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
      await checkAuth();
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
    } on FirebaseException catch (e) {
      Exceptionemitter.addException(e.toString());
      throw e.code;
    } catch (e) {
      throw e;
    }
  }

  Future get profile async {
    try {
      await checkAuth();
      if (AppData().accessType == AccessType.coach) {
        DocumentSnapshot coach = await firestore
            .collection(Collections.Coach.id)
            .doc(firebaseAuth.currentUser!.uid)
            .get();

        return coach.data();
      } else if (AppData().accessType == AccessType.athlete) {
        DocumentSnapshot athlete = await firestore
            .collection(Collections.Athlete.id)
            .doc(firebaseAuth.currentUser!.uid)
            .get();

        return athlete.data();
      } else {
        Exceptionemitter.addException(
            "You are not authorized to access this data");
      }
    } on FirebaseException catch (e) {
      Exceptionemitter.addException(e.toString());
      throw e.code;
    } catch (e) {
      throw e;
    }
  }

  Future get orgData async {
    try {
      await checkAuth();
      if (firebaseAuth.currentUser != null) {
        String uid = firebaseAuth.currentUser!.uid;

        QuerySnapshot coachData = await firestore
            .collection(Collections.Ledger.id)
            .where("coach_id", isEqualTo: uid)
            .get();

        if (coachData.docs.length != 0) {
          AppData().org_id = coachData.docs[0]["organization_id"];
          DocumentSnapshot orgData = await firestore
              .collection(Collections.Organization.id)
              .doc(AppData().org_id)
              .get();
          return;
        } else {
          Exceptionemitter.addException("User not authorized!");
          return;
        }
      }
      Exceptionemitter.addException(
          "User not logged in or Can't retrive user data");
    } on FirebaseException catch (e) {
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

  Future get getTeamList async {
    try {
      await checkAuth();
      if (AppData().accessType == AccessType.coach) {
        QuerySnapshot teamData = await firestore
            .collection(Collections.Team.id)
            .where('organization_id', isEqualTo: AppData().org_id!)
            .get();

        return teamData.docs;
      } else {
        Exceptionemitter.addException(
            "You are not authorized to access this data");
      }
    } on FirebaseException catch (e) {
      Exceptionemitter.addException(e.toString());
      throw e.code;
    } catch (e) {
      throw e;
    }
  }

  Future get getCoachList async {
    try {
      await checkAuth();
      if (AppData().accessType == AccessType.coach) {
        QuerySnapshot ledgerData = await firestore
            .collection(Collections.Ledger.id)
            .where('organization_id', isEqualTo: AppData().org_id!)
            .get();

        Set<String> coachIDs = {};

        ledgerData.docs.forEach((element) {
          coachIDs.add(element['coach_id']);
        });

        var response = [];

        for (String element in coachIDs) {
          DocumentSnapshot<Map<String, dynamic>> temp = await firestore
              .collection(Collections.Coach.id)
              .doc(element)
              .get();
          response.add(temp);
        }

        return response;
      } else {
        Exceptionemitter.addException(
            "You are not authorized to access this data");
      }
    } on FirebaseException catch (e) {
      Exceptionemitter.addException(e.toString());
      throw e.code;
    } catch (e) {
      throw e;
    }
  }

  Future get getAthleteList async {
    try {
      await checkAuth();
      if (AppData().accessType == AccessType.coach) {
        QuerySnapshot ledgerData = await firestore
            .collection(Collections.Ledger.id)
            .where('organization_id', isEqualTo: AppData().org_id!)
            .get();

        Set<String> athleteIDs = {};

        ledgerData.docs.forEach((element) {
          athleteIDs.add(element['athlete_id']);
        });

        var response = [];

        for (String element in athleteIDs) {
          DocumentSnapshot<Map<String, dynamic>> temp = await firestore
              .collection(Collections.Athlete.id)
              .doc(element)
              .get();
          response.add(temp);
        }

        return response;
      } else {
        Exceptionemitter.addException(
            "You are not authorized to access this data");
      }
    } on FirebaseException catch (e) {
      Exceptionemitter.addException(e.toString());
      throw e.code;
    } catch (e) {
      throw e;
    }
  }

  Future get getSensorList async {
    try {
      await checkAuth();
      if (AppData().accessType == AccessType.coach) {
        QuerySnapshot ledgerData = await firestore
            .collection(Collections.Ledger.id)
            .where('organization_id', isEqualTo: AppData().org_id!)
            .get();

        Set<String> athleteIDs = {};

        ledgerData.docs.forEach((element) {
          athleteIDs.add(element['athlete_id']);
        });

        QuerySnapshot<Map<String, dynamic>> temp = await firestore
            .collection(Collections.Sensor.id)
            .where('user', whereIn: athleteIDs.toList())
            .get();

        return temp.docs;
      } else {
        Exceptionemitter.addException(
            "You are not authorized to access this data");
      }
    } on FirebaseException catch (e) {
      Exceptionemitter.addException(e.toString());
      throw e.code;
    } catch (e) {
      throw e;
    }
  }

  checkAuth() async {
    if (AppData().user != null) {
      if (!AppData().user!.emailVerified) {
        AppData().user!.sendEmailVerification();
        throw 'Email verification incomplete!';
      }
    } else {
      currentUser;
    }
    if (AppData().accessType == null) {
      accessType;
    }
    if (AppData().org_id == null) {
      orgData;
    }
  }
}
