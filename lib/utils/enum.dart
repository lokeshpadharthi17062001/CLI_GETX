import 'package:conqur_backend_test/utils/constants.dart';

enum Command {
  test,
  signUp,
  signIn,
  signOut,
  accessType,
  currentUser,
  updatePassword,
  passwordResetLink,
  passwordReset,
  getCoachTeam,
  unknown
}

extension CommandParserExtension on String {
  Command get command {
    switch (this) {
      case TEST_COMMAND:
        return Command.test;
      case SIGN_UP_COMMAND:
        return Command.signUp;
      case SIGN_IN_COMMAND:
        return Command.signIn;
      case SIGN_OUT_COMMAND:
        return Command.signOut;
      case CURRENT_USER_COMMAND:
        return Command.currentUser;
      case ACCESS_TYPE_COMMAND:
        return Command.accessType;
      case COACH_TEAM_DATA:
        return Command.getCoachTeam;
      case UPDATE_PASSWORD_COMMAND:
        return Command.updatePassword;
      case RESET_PASSWORD_LINK_COMMAND:
        return Command.passwordResetLink;
      // case RESET_PASSWORD_COMMAND:
      //   return Command.passwordReset;
      default:
        return Command.unknown;
    }
  }
}

enum Collections {
  Athlete,
  Coach,
  Team,
  Organization,
  Ledger,
  Invites,
  Sensor,
  Firmware,
  UniversalEvent,
  UserEvent,
}

extension CollectionsExtension on Collections {
  String get id {
    switch (this) {
      case Collections.Athlete:
        return ATHLETE_COLLECTION;
      case Collections.Coach:
        return COACH_COLLECTION;
      case Collections.Team:
        return TEAM_COLLECTION;
      case Collections.Organization:
        return ORGANIZATION_COLLECTION;
      case Collections.Ledger:
        return LEDGER_COLLECTION;
      case Collections.Invites:
        return INVITES_COLLECTION;
      case Collections.Sensor:
        return SENSOR_COLLECTION;
      case Collections.Firmware:
        return FIRMWARE_COLLECTION;
      case Collections.UniversalEvent:
        return UNIVERSAL_EVENT_COLLECTION;
      case Collections.UserEvent:
        return USER_EVENT_COLLECTION;
      default:
        return "";
    }
  }
}

enum AccessType{
  athlete,
  coach,
  unauthorized
}
