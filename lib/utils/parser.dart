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
        case Command.getCoachTeam:
          return FirebaseRepository().getCoachTeam;
        case Command.updatePassword:
          checkLen(splitted.length, 1);
          return FirebaseRepository().updatePassword(splitted[1]);
        case Command.passwordResetLink:
          checkLen(splitted.length, 1);
          return FirebaseRepository().resetPasswordLink(splitted[1]);
        // case Command.passwordReset:
        //   checkLen(splitted.length, 2);
        //   return FirebaseRepository().resetPassword(splitted[1], splitted[2]);
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
