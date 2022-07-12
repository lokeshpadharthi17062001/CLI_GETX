import 'package:conqur_backend_test/firebase/repository.dart';
import 'package:conqur_backend_test/utils/enum.dart';

class CommandParser {
  parse(String? command) {
    try {
      List<String> splitted = command!.split(' ');
      switch (splitted[0].command) {
        case Command.test:
          return Future(() => splitted.toString().replaceAll(RegExp(r','), ""));
        case Command.signUp:
          checkLen(splitted.length, 2);
          return FirebaseRepository().signUp(splitted[1], splitted[2]);
        case Command.signIn:
          checkLen(splitted.length, 2);
          return FirebaseRepository().signIn(splitted[1], splitted[2]);
        case Command.currentUser:
          return FirebaseRepository().currentUser;
        case Command.signOut:
          return FirebaseRepository().signout;
        case Command.accessType:
          return FirebaseRepository().accessType;
        case Command.getTeamList:
          return FirebaseRepository().getTeamList;
        case Command.getCoachList:
          return FirebaseRepository().getCoachList;
        case Command.getAthleteList:
          return FirebaseRepository().getAthleteList;
        case Command.getSensorList:
          return FirebaseRepository().getSensorList;
        case Command.getOrgData:
          return FirebaseRepository().orgData;
        case Command.getProfile:
          return FirebaseRepository().profile;
        case Command.editProfile:
          checkLen(splitted.length, 1);
          return FirebaseRepository().editProfile(splitted[1]);
        case Command.updatePassword:
          checkLen(splitted.length, 1);
          return FirebaseRepository().updatePassword(splitted[1]);
        case Command.passwordReset:
          checkLen(splitted.length, 1);
          return FirebaseRepository().resetPassword(splitted[1]);
        case Command.addTeam:
          checkLen(splitted.length, 2);
          return FirebaseRepository().addTeam(splitted[1],splitted[2]);
        case Command.addCoach:
          checkLen(splitted.length,1);
          return FirebaseRepository().addCoach(splitted[1]);
        case Command.removeCoach:
          checkLen(splitted.length, 1);
          return FirebaseRepository().removeCoach(splitted[1]);
        case Command.removeTeam:
          checkLen(splitted.length, 1);
          return FirebaseRepository().removeTeam(splitted[1]);
        case Command.addAthlete:
          checkLen(splitted.length, 1);
          return FirebaseRepository().addAthlete(splitted[1]);
        case Command.removeAthlete:
          checkLen(splitted.length, 1);
          return FirebaseRepository().removeAthlete(splitted[1]);
        case Command.registerSensor:
          checkLen(splitted.length, 1);
          return FirebaseRepository().registerSensor(splitted[1]);
        case Command.unRegisterSensor:
          checkLen(splitted.length, 1);
          return FirebaseRepository().unRegisterSensor(splitted[1]);
        case Command.assignSensor:
          checkLen(splitted.length, 2);
          return FirebaseRepository().assignSensor(splitted[1], splitted[2]);
        case Command.unassignSensor:
          checkLen(splitted.length, 1);
          return FirebaseRepository().unassignSensor(splitted[1]);
        case Command.mySensor:
          return FirebaseRepository().mySensor();
        case Command.assignCoach:
          checkLen(splitted.length, 2);
          return FirebaseRepository().assignCoach(splitted[1], splitted[2]);
        case Command.unassignCoach:
          checkLen(splitted.length, 2);
          return FirebaseRepository().unassignCoach(splitted[1], splitted[2]);
        case Command.assignAthlete:
          checkLen(splitted.length, 2);
          return FirebaseRepository().assignAthlete(splitted[1], splitted[2]);
        case Command.unassignAthlete:
          checkLen(splitted.length, 2);
          return FirebaseRepository().unassignAthlete(splitted[1], splitted[2]);
        case Command.createOrganization:
          checkLen(splitted.length,3);
          return FirebaseRepository().createOrganization(splitted[1], splitted[2], splitted[3]);
        case Command.inviteOrganization:
          checkLen(splitted.length, 1);
          return FirebaseRepository().inviteOrganization(splitted[1]);
        case Command.help:
          checkLen(splitted.length,1);
          return FirebaseRepository().help(splitted[1]);
        case Command.getreport:
          return FirebaseRepository().getReport();
        case Command.getmanager:
          return FirebaseRepository().getManager();
        case Command.createSession:
          checkLen(splitted.length, 1);
          return FirebaseRepository().addSession(splitted[1]);
        case Command.getSessiondata:
          checkLen(splitted.length, 1);
          return FirebaseRepository().getSessiondata(splitted[1]);
        case Command.viewSessiondata:
          checkLen(splitted.length, 1);
          return FirebaseRepository().viewSessiondata(splitted[1]);

        case Command.cacheProfile:
          return FirebaseRepository().cacheProfile();
        case Command.unknown:
          throw "Unknown Command";
        default:
          throw "Unknown Command";
      }
    } catch (e) {
      throw e;
    }
  }

  void checkLen(int len, int required) {
    if ((len - 1) != required) throw "Invalid parameters";
  }
}
