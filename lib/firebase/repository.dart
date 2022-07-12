import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:conqur_backend_test/utils/app_data.dart';
import 'package:conqur_backend_test/utils/emitter.dart';
import 'package:conqur_backend_test/utils/enum.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class FirebaseRepository {
  static final FirebaseRepository _firebaserepository =
      FirebaseRepository._internal();

  factory FirebaseRepository() {
    return _firebaserepository;
  }

  FirebaseRepository._internal();

  Emitter Exceptionemitter = Emitter();
  var user_data;
  final Dio _httpClient = Dio();

  final base_url = "https://us-central1-testproject-3c42a.cloudfunctions.net/";

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseFunctions functions = FirebaseFunctions.instance;

  var help_response = {
    "message": {
      "test": "test message",
      "signup": "signup email password",
      "signin": "signin email password",
      "signout": "signout",
      "currentuser": "currentuser",
      "updatepwd": "updatepwd",
      "resetpwd": "resetpwd",
      "accesstype": "accesstype",
      "getprofile": "getprofile",
      "editprofile": "editprofile field:newValue ---if editing one field\n\t"
          "editprofile field1:newValue1&field2:newValue2  ---if editing multiple fields\n\t"
          "Note: If we want to pass the integer then assign newValue with prefixing with underscore\n\tEx:(field:_newValue)",
      "add_team": "add_time teamName sport_type",
      "remove_team": "remove_team team_id",
      "add_coach": "add_coach email",
      "remove_coach": "remove_coach coach_id",
      "assign_coach": "assign_coach team_id coach_id",
      "unassign_coach": "unassign_coach team_id coach_id",
      "add_athlete": "add_athlete email",
      "remove_athlete": "remove_athlete athlete_id",
      "assign_athlete": "assign_athlete team_id athlete_id",
      "unassign_athlete": "unassign_athlete team_id athlete_id",
      "register_sensor": "register_sensor sensor_id",
      "unregister_sensor": "unregister_sensor sensor_id",
      "assign_sensor": "assign_sensor athlete_id sensor_id",
      "unassign_sensor": "unassign_sensor sensor_id",
      "mysensor": "mysensor",
    }
  };

  Future signUp(String email, String password) async {
    try {
      if (firebaseAuth.currentUser != null) {
        Exceptionemitter.addException(
            'User already logged in,Signout the user and Try Again....');
        return;
      }
      late UserCredential user;
      await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((userData) {
        userData.user?.sendEmailVerification();
        user = userData;
        AppData().user = user.user;
      });
      await firebaseAuth.signOut();
      return "Signed Up Successfully and Verification mail sent to $email";
    } on FirebaseAuthException catch (e) {
      Exceptionemitter.addException(e.toString());
      throw e.code;
    } catch (e) {
      throw e;
    }
  }

  Future signIn(String email, String password) async {
    try {
      if (firebaseAuth.currentUser != null) {
        Exceptionemitter.addException("User already logged in....");
        return;
      }
      UserCredential user = await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);

      if (!user.user!.emailVerified) {
        user.user?.sendEmailVerification();
        Exceptionemitter.addException(
            "Pending email verification...\nIf you cant find verification link in your inbox please do check your SPAM folder once");
        return;
      }
      await cacheProfile();
      AppData().user = user.user;
      return 'Signed in with the email $email\nHello $user_data';
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
          "User not logged in or Can't retrieve user data");
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
        print(user_data);
        user_data = '';
        user_data = '';
        return "Signed out successfully!";
      }
      Exceptionemitter.addException(
          "User not logged in or Can't retrieve user data");
    } on FirebaseAuthException catch (e) {
      Exceptionemitter.addException(e.toString());
      throw e.code;
    } catch (e) {
      throw e;
    }
  }

  Future get accessType async {
    try {
      if (firebaseAuth.currentUser != null) {
        String? email = firebaseAuth.currentUser?.email;
        QuerySnapshot athlete = await firestore
            .collection(Collections.Athletes.id)
            .where("email", isEqualTo: email)
            .get();
        QuerySnapshot coach = await firestore
            .collection(Collections.Coach.id)
            .where("email", isEqualTo: email)
            .get();
        QuerySnapshot organization = await firestore
            .collection(Collections.Organization.id)
            .where("email", isEqualTo: email)
            .get();
        if (athlete.size != 0) {
          AppData().accessType = AccessType.athlete;
          return "Athlete access";
        } else if (coach.size != 0) {
          AppData().accessType = AccessType.coach;
          return "Coach access";
        } else if (organization.size != 0) {
          AppData().accessType = AccessType.organization_admin;
          return "Organization Admin access";
        } else {
          Exceptionemitter.addException("User not authorized!");
          return;
        }
      }
      Exceptionemitter.addException(
          "User not logged in or Can't retrieve user data");
    } on FirebaseException catch (e) {
      Exceptionemitter.addException(e.toString());
      throw e.code;
    } catch (e) {
      throw e;
    }
  }

  Future get profile async {
    try {
      var email = firebaseAuth.currentUser?.email;
      if (firebaseAuth.currentUser == null) {
        return "User not logged in or Can't retrieve user data";
      }
      if (AppData().accessType == AccessType.coach) {
        QuerySnapshot coach = await firestore
            .collection(Collections.Coach.id)
            .where("email", isEqualTo: email)
            .get();
        return coach.docs[0].data();
      } else if (AppData().accessType == AccessType.athlete) {
        QuerySnapshot athlete = await firestore
            .collection(Collections.Athletes.id)
            .where("email", isEqualTo: email)
            .get();
        return athlete.docs[0].data();
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

  editProfile(String edit_set) async {
    try {
      var fields = edit_set.split('&');
      var field_set = <String, dynamic>{};
      for (int i = 0; i < fields.length; i++) {
        var mapping = fields[i].split(':');
        field_set[mapping[0]] = (mapping[1] == 'null')
            ? null
            : (mapping[1].substring(0, 1) == '_')
                ? int.parse(mapping[1].substring(1, mapping[1].length))
                : mapping[1];
        print(mapping[1].substring(0, 1));
      }
      var access_type = await accessType;
      var type = {
        'Coach access': 'Coach',
        'Athlete access': 'Athletes',
        'Organization Admin access': 'Organization'
      };
      var org = await firestore
          .collection(type[access_type].toString())
          .where('email', isEqualTo: firebaseAuth.currentUser?.email)
          .get();
      await firestore
          .collection('Organization')
          .doc(org.docs[0].id)
          .update(field_set);
    } catch (e) {
      throw (e);
    }
  }

  Future get orgData async {
    try {
      // await checkAuth();
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
          return orgData.data();
        } else {
          return "User not authorized!";
        }
      }
      Exceptionemitter.addException(
          "User not logged in or Can't retrieve user data");
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
          "User not logged in or Can't retrieve user data");
    } on FirebaseAuthException catch (e) {
      Exceptionemitter.addException(e.toString());
      throw e.code;
    } catch (e) {
      throw e;
    }
  }

  Future resetPassword(String email) async {
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
      var org = await firestore
          .collection('Organization')
          .where('email', isEqualTo: firebaseAuth.currentUser?.email)
          .get();
      QuerySnapshot teamData = await firestore
          .collection('Team')
          .where('organization_id', isEqualTo: org.docs[0].id)
          .get();
      if (teamData.size == 0) {
        return 'Coaches not there in your Organization';
      }
      Set<String> teamNames = {};
      teamData.docs.forEach((element) {
        Map<String, dynamic>? a = element.data() as Map<String, dynamic>?;
        teamNames.add(a!['name']);
      });
      return teamNames;
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
      if (AppData().accessType == AccessType.organization_admin) {
        var organization = await firestore
            .collection(Collections.Organization.id)
            .where("email", isEqualTo: firebaseAuth.currentUser?.email)
            .get();
        QuerySnapshot ledgerData = await firestore
            .collection(Collections.Ledger.id)
            .where('organization_id', isEqualTo: organization.docs[0].id)
            .where('type', isEqualTo: 'Coach')
            .get();
        if (ledgerData.size == 0) {
          return 'No Coaches in Organization';
        }
        Set<String> coachIDs = {};
        ledgerData.docs.forEach((element) {
          Map<String, dynamic>? a = element.data() as Map<String, dynamic>?;
          coachIDs.add(a!['coach_id']);
        });
        var response = [];
        for (String element in coachIDs) {
          DocumentSnapshot<Map<String, dynamic>> temp = await firestore
              .collection(Collections.Coach.id)
              .doc(element)
              .get();
          response.add(temp['first_name'].toString() +
              " " +
              temp['last_name'].toString());
        }
        return response.toString();
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
      if (AppData().accessType == AccessType.organization_admin ||
          AppData().accessType == AccessType.coach) {
        var organization = await firestore
            .collection(Collections.Organization.id)
            .where("email", isEqualTo: firebaseAuth.currentUser?.email)
            .get();
        QuerySnapshot ledgerData = await firestore
            .collection(Collections.Ledger.id)
            .where('organization_id', isEqualTo: organization.docs[0].id)
            .where('type', isEqualTo: 'Athlete')
            .get();
        if (ledgerData.size == 0) {
          return 'No Athletes in Organization';
        }
        Set<String> athleteIDs = {};
        ledgerData.docs.forEach((element) {
          Map<String, dynamic>? a = element.data() as Map<String, dynamic>?;
          athleteIDs.add(a!['athlete_id']);
        });
        var response = [];
        for (String element in athleteIDs) {
          DocumentSnapshot<Map<String, dynamic>> temp = await firestore
              .collection(Collections.Athletes.id)
              .doc(element)
              .get();
          response.add(temp['first_name'].toString() +
              " " +
              temp['last_name'].toString());
        }
        return response.toString();
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
      if (firebaseAuth.currentUser != null) {
        var access_type = await accessType;
        var type = {
          'Athlete access': 'Athletes',
          'Coach access': 'Coach',
          'Organization Admin access': 'Organization'
        };
        var user_exists = await firestore
            .collection(type[access_type].toString())
            .where("email", isEqualTo: firebaseAuth.currentUser?.email)
            .get();
        if (type[access_type].toString() == 'Athletes') {
          QuerySnapshot<Map<String, dynamic>> temp = await firestore
              .collection(Collections.Sensor.id)
              .where("athlete_id", isEqualTo: user_exists.docs[0].id)
              .get();
          return temp.docs[0].data()['sensor_id'];
        }
        QuerySnapshot ledgerData = await firestore
            .collection(Collections.Ledger.id)
            .where('organization_id', isEqualTo: user_exists.docs[0].id)
            .where('type', isEqualTo: 'Athlete')
            .get();
        if (ledgerData.size == 0) {
          return 'No Athletes in Organization';
        }
        Set<String> athleteIDs = {};
        ledgerData.docs.forEach((element) {
          Map<String, dynamic>? a = element.data() as Map<String, dynamic>?;
          athleteIDs.add(a!['athlete_id']);
        });
        Set<String> sensorIDs = {};
        for (String element in athleteIDs) {
          QuerySnapshot<Map<String, dynamic>> temp = await firestore
              .collection(Collections.Sensor.id)
              .where("athlete_id", isEqualTo: element)
              .get();
          if (temp.size == 0) return 'No sensors in Organization';
          temp.docs.forEach((element) {
            Map<String, dynamic>? a = element.data();
            sensorIDs.add(a['sensor_id']);
          });
        }
        return sensorIDs;
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

  inviteOrganization(String mail) async {
    try {
      var requestUrl = base_url + 'inviteOrganization?mail=$mail';
      var response = await Dio().post(requestUrl);
      return response;
    } catch (e) {
      throw e;
    }
  }

  createOrganization(String name, String email, String mobile) async {
    try {
      var data = jsonEncode({
        'name': '$name',
        'email': '$email',
        'mobile': int.parse(mobile),
        'sport_type': null,
        'gst': null,
      });
      var requestUrl = base_url + 'createOrganization';
      var response = await Dio().post(
        requestUrl,
        data: data,
      );
      return 'Created Organization ${response.data}';
    } catch (e) {
      Exceptionemitter.addException(e.toString());
      throw e;
    }
  }

  addTeam(String teamName, String sport_type) async {
    try {
      HttpsCallableResult result =
          await FirebaseFunctions.instance.httpsCallable('addTeam').call({
        'name': '$teamName',
        'sport_type': '$sport_type',
        'head_coach': null,
      });
      return result.data['success'];
    } on FirebaseFunctionsException catch (e) {
      Exceptionemitter.addException(e.toString());
      throw e;
    }
  }

  removeTeam(String team_id) async {
    try {
      HttpsCallableResult result =
          await FirebaseFunctions.instance.httpsCallable('removeTeam').call({
        'team_id': '$team_id',
      });
      return result.data;
    } on FirebaseFunctionsException catch (e) {
      Exceptionemitter.addException(e.toString());
      throw e;
    }
  }

  addCoach(String email) async {
    try {
      QuerySnapshot coach_exists = await firestore
          .collection(Collections.Coach.id)
          .where("email", isEqualTo: email)
          .get();
      HttpsCallableResult result;
      if (coach_exists.size != 0) {
        result =
            await FirebaseFunctions.instance.httpsCallable('addCoach').call({
          'email': '$email',
        });
      } else {
        result =
            await FirebaseFunctions.instance.httpsCallable('addCoach').call({
          'email': '$email',
          'first_name': null,
          'last_name': null,
          'city': null,
          'address': null,
          'pincode': null,
          'country': null,
          'state': null,
          'height_cm': null,
          'weight_kg': null,
        });
      }

      return result.data;
    } on FirebaseFunctionsException catch (e) {
      Exceptionemitter.addException(e.toString());
      throw e;
    }
  }

  removeCoach(String coach_id) async {
    try {
      HttpsCallableResult result =
          await FirebaseFunctions.instance.httpsCallable('removeCoach').call({
        'coach_id': '$coach_id',
      });
      return result.data;
    } on FirebaseFunctionsException catch (e) {
      Exceptionemitter.addException(e.toString());
      throw e;
    }
  }

  assignCoach(String team_id, String coach_id) async {
    try {
      HttpsCallableResult result =
          await FirebaseFunctions.instance.httpsCallable('assignCoach').call({
        'team_id': '$team_id',
        'coach_id': '$coach_id',
      });
      return result.data;
    } on FirebaseFunctionsException catch (e) {
      Exceptionemitter.addException(e.toString());
      throw e;
    }
  }

  unassignCoach(String team_id, String coach_id) async {
    try {
      HttpsCallableResult result =
          await FirebaseFunctions.instance.httpsCallable('unAssignCoach').call({
        'team_id': '$team_id',
        'coach_id': '$coach_id',
      });
      return result.data;
    } on FirebaseFunctionsException catch (e) {
      Exceptionemitter.addException(e.toString());
      throw e;
    }
  }

  addAthlete(String email) async {
    try {
      QuerySnapshot athlete_exists = await firestore
          .collection(Collections.Athletes.id)
          .where("email", isEqualTo: email)
          .get();
      HttpsCallableResult result;
      if (athlete_exists.size != 0) {
        result =
            await FirebaseFunctions.instance.httpsCallable('addAthlete').call({
          'email': '$email',
        });
      } else {
        result =
            await FirebaseFunctions.instance.httpsCallable('addAthlete').call({
          'email': '$email',
          'first_name': null,
          'last_name': null,
          'city': null,
          'address': null,
          'pincode': null,
          'country': null,
          'state': null,
          'height_cm': null,
          'weight_kg': null,
        });
      }
      return result.data;
    } on FirebaseFunctionsException catch (e) {
      Exceptionemitter.addException(e.toString());
      throw e;
    }
  }

  removeAthlete(String athlete_id) async {
    try {
      HttpsCallableResult result =
          await FirebaseFunctions.instance.httpsCallable('removeAthlete').call({
        'athlete_id': '$athlete_id',
      });
      return result.data;
    } on FirebaseFunctionsException catch (e) {
      Exceptionemitter.addException(e.toString());
      throw e;
    }
  }

  assignAthlete(String team_id, String athlete_id) async {
    try {
      HttpsCallableResult result =
          await FirebaseFunctions.instance.httpsCallable('assignAthlete').call({
        'team_id': '$team_id',
        'athlete_id': '$athlete_id',
      });
      return result.data;
    } on FirebaseFunctionsException catch (e) {
      Exceptionemitter.addException(e.toString());
      throw e;
    }
  }

  unassignAthlete(String team_id, String athlete_id) async {
    try {
      HttpsCallableResult result = await FirebaseFunctions.instance
          .httpsCallable('unassignAthlete')
          .call({
        'team_id': '$team_id',
        'athlete_id': '$athlete_id',
      });
      return result.data;
    } on FirebaseFunctionsException catch (e) {
      Exceptionemitter.addException(e.toString());
      throw e;
    }
  }

  registerSensor(String sensor_id) async {
    try {
      HttpsCallableResult result = await FirebaseFunctions.instance
          .httpsCallable('registerSensor')
          .call({
        'sensor_id': '$sensor_id',
        'athlete_id': null,
        'firmware_version': null,
        'battery': 0,
        'last_connected_time': null
      });
      return result.data;
    } on FirebaseFunctionsException catch (e) {
      Exceptionemitter.addException(e.toString());
      throw e;
    }
  }

  unRegisterSensor(String sensor_id) async {
    try {
      HttpsCallableResult result = await FirebaseFunctions.instance
          .httpsCallable('unRegisterSensor')
          .call({
        'sensor_id': '$sensor_id',
      });
      return result.data;
    } on FirebaseFunctionsException catch (e) {
      Exceptionemitter.addException(e.toString());
      throw e;
    }
  }

  assignSensor(String athlete_id, String sensor_id) async {
    try {
      HttpsCallableResult result =
          await FirebaseFunctions.instance.httpsCallable('assignSensor').call({
        'sensor_id': '$sensor_id',
        'athlete_id': '$athlete_id',
      });
      var hex_to_int = [];
      for (int i = 0; i < 4; i++) {
        hex_to_int.add(int.parse(
            result.data['sensor_token'].substring(i, i + 2),
            radix: 16));
      }
      debugPrint(hex_to_int.toString());
      return result.data;
    } on FirebaseFunctionsException catch (e) {
      Exceptionemitter.addException(e.toString());
      throw e;
    }
  }

  cacheProfile() async {
    try {
      var access_type = await accessType;
      var type = {
        'Coach access': 'Coach',
        'Athlete access': 'Athletes',
        'Organization Admin access': 'Organization'
      };
      var user_data1 = await firestore
          .collection(type[access_type].toString())
          .where('email', isEqualTo: firebaseAuth.currentUser?.email)
          .get();
      if (access_type == 'Organization Admin access') {
        user_data = user_data1.docs[0].data()['name'].toString();
        return user_data;
      }
      user_data = user_data1.docs[0].data()['first_name'].toString() +
          " " +
          user_data1.docs[0].data()['last_name'].toString();
      return (user_data);

    } catch (e) {
      throw (e);
    }
  }

  getSessiondata(String session_id) async {
    try {
      HttpsCallableResult result = await FirebaseFunctions.instance
          .httpsCallable('get_session_data')
          .call({'session_id': '$session_id'});
      var debug_info='';
      for(var i=0;i<result.data['debug_info'].length;i++) {
        debug_info+=result.data['debug_info'][i].toString()+'\n';
      }
      Exceptionemitter.addException(debug_info);
    } catch (e) {
      throw (e);
    }
  }

  viewSessiondata(String session_id) async {
    try {
      return 'Plotting the Data......';
    } catch (e) {
      throw(e);
    }
  }
  addSession(String filename)async {
    String hex = await rootBundle.loadString(filename);
    var hex_list=hex.split('\n');
    var data={
      'athlete_id':'MeeQ8Qn9GALmE5ths88x',
      'coach_id':'Hrw6ltgPMXOGoaKbR5rf',
      'created':DateTime.now(),
      'start_time':DateTime.now(),
      'end_time':DateTime.now(),
      'end_timezone':'iuy',
      'firmware_version':'ijuygfc',
      'hex_data':hex_list,
      'name':null,
      'read_packets':null,
      'sensor':null,
      'session_completed_by':null,
      'session_status':null
    };
    firestore.collection('Session').add(data);
    return 'session created';
    // var a=await firestore.collection('Athlete').doc(filename).delete();
    // var batch = firestore.batch();
    // // a.forEach((doc) => {
    // // batch.delete(doc.reference)
    // // });
    // // var batch = firestore.batch();
    //
    //
    // batch.delete(a);

    // await batch.commit();
    // await batch.commit();
  }

  unassignSensor(String sensor_id) async {
    try {
      HttpsCallableResult result = await FirebaseFunctions.instance
          .httpsCallable('unAssignSensor')
          .call({
        'sensor_id': '$sensor_id',
        'athlete_id': 'f6ctJntVNyKGD2LD6WFk',
      });
      return result.data;
    } on FirebaseFunctionsException catch (e) {
      Exceptionemitter.addException(e.toString());
      throw e;
    }
  }

  mySensor() async {
    await accessType;
    if (AppData().accessType == AccessType.athlete) {
      var athlete_id = await firestore
          .collection(Collections.Athletes.id)
          .where('email', isEqualTo: firebaseAuth.currentUser?.email)
          .get();
      print(firebaseAuth.currentUser?.email);
      var my_sensor = await firestore
          .collection(Collections.Sensor.id)
          .where('athlete_id', isEqualTo: athlete_id.docs[0].id)
          .get();
      if (my_sensor.size != 0) {
        return 'Sensor ${my_sensor.docs[0].data()['sensor_id']} registered for you';
      } else {
        return 'No sensor registered for you';
      }
    }
    return;
  }

  getReport() async {
    try {
      var athlete_id = await firestore
          .collection('Athletes')
          .where('email', isEqualTo: firebaseAuth.currentUser?.email)
          .get();
      var report = await firestore
          .collection('Report')
          .where('athlete_id', isEqualTo: athlete_id.docs[0].id)
          .get();
      return report.docs;
    } catch (e) {
      throw e;
    }
  }

  getManager() async {
    try {
      var athlete_id = await firestore
          .collection('Athletes')
          .where('email', isEqualTo: firebaseAuth.currentUser?.email)
          .get();
      var athlete_assign = await firestore
          .collection('Ledger')
          .where('athlete_id', isEqualTo: athlete_id.docs[0].id)
          .where('type', isEqualTo: 'AthleteAssigned')
          .get();
      var coach_assign = await firestore
          .collection('Ledger')
          .where('team_id', isEqualTo: athlete_assign.docs[0]['team_id'])
          .where('type', isEqualTo: 'CoachAssinged')
          .get();
      return coach_assign.docs;
    } catch (e) {
      throw (e);
    }
  }

  help(String function) async {
    if (function == "--") {
      var res = '';
      help_response['message']?.forEach((key, value) {
        res += '$key : $value' + '\n';
      });
      return res.substring(0, res.length - 1);
    }
    return help_response['message']![function];
  }

  cfCallableTest() async {
    try {
      HttpsCallableResult result =
          await FirebaseFunctions.instance.httpsCallable('testFunc').call();
      return result.data;
    } on FirebaseFunctionsException catch (e) {
      Exceptionemitter.addException(e.toString());
      throw e;
    }
  }

  cfHttpTest() async {
    try {
      Response result = await _httpClient.get(base_url + "randomNumber");
      return result.data;
    } on DioError catch (e) {
      Exceptionemitter.addException(e.toString());
      throw e;
    }
  }
}
