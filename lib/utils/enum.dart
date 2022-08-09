import 'package:conqur_backend_test/utils/constants.dart';

enum Command {
  test,
  clear_response,
  signUp,
  signIn,
  signOut,
  accessType,
  currentUser,
  updatePassword,
  passwordReset,
  getTeamList,
  getCoachList,
  getAthleteList,
  getSensorList,
  getProfile,
  editProfile,
  cacheProfile,
  getOrgData,
  addTeam,
  addCoach,
  removeCoach,
  removeTeam,
  addAthlete,
  removeAthlete,
  assignCoach,
  unassignCoach,
  assignAthlete,
  unassignAthlete,
  registerSensor,
  unRegisterSensor,
  assignSensor,
  unassignSensor,
  mySensor,
  createOrganization,
  inviteOrganization,
  createSession,
  getSessiondata,
  viewSessiondata,
  help,
  getreport,
  getmanager,
  unknown
}

extension CommandParserExtension on String {
  Command get command {
    switch (this) {
      case TEST_COMMAND:
        return Command.test;
      case CLEAR_RESPONSE:
        return Command.clear_response;
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
      case TEAM_LIST:
        return Command.getTeamList;
      case COACH_LIST:
        return Command.getCoachList;
      case ATHLETE_LIST:
        return Command.getAthleteList;
      case SENSOR_LIST:
        return Command.getSensorList;
      case USER_PROFILE:
        return Command.getProfile;
      case EDIT_PROFILE:
        return Command.editProfile;
      case CACHE_PROFILE:
        return Command.cacheProfile;
      case UPDATE_PASSWORD_COMMAND:
        return Command.updatePassword;
      case RESET_PASSWORD:
        return Command.passwordReset;
      case ORGANIZATION_DATA_COMMAND:
        return Command.getOrgData;
      case ADD_TEAM:
        return Command.addTeam;
      case ADD_COACH:
        return Command.addCoach;
      case REMOVE_COACH:
        return Command.removeCoach;
      case REMOVE_TEAM:
        return Command.removeTeam;
      case ADD_ATHLETE:
        return Command.addAthlete;
      case REMOVE_ATHLETE:
        return Command.removeAthlete;
      case ASSIGN_ATHLETE:
        return Command.assignAthlete;
      case ASSIGN_COACH:
        return Command.assignCoach;
      case UNASSIGN_COACH:
        return Command.unassignCoach;
      case UNASSIGN_ATHLETE:
        return Command.unassignAthlete;
      case REGISTER_SENSOR:
        return Command.registerSensor;
      case UNREGISTER_SENSOR:
        return Command.unRegisterSensor;
      case ASSIGN_SENSOR:
        return Command.assignSensor;
      case UNASSIGN_SENSOR:
        return Command.unassignSensor;
      case ASSIGNED_SENSOR:
        return Command.mySensor;
      case CREATE_ORGANISATION:
        return Command.createOrganization;
      case INVITE_ORGANISATION:
        return Command.inviteOrganization;
      case CREATE_SESSION:
        return Command.createSession;
      case GET_SESSION_DATA:
        return Command.getSessiondata;
      case VIEW_SESSION_DATA:
        return Command.viewSessiondata;
      case HELP_COMMAND:
        return Command.help;
      case GET_REPORT:
        return Command.getreport;
      case GET_MANAGER:
        return Command.getmanager;
      default:
        return Command.unknown;
    }
  }
}

enum Collections {
  Athletes,
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
      case Collections.Athletes:
        return ATHLETES_COLLECTION;
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

enum AccessType { athlete, coach,organization_admin, unauthorized }
