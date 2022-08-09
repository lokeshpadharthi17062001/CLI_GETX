import 'package:flutter/material.dart';

//font size
const double FONT_SIZE = 16;

//colors
const Color RESPONSE_COLOR = Colors.white;
Color COMMAND_COLOR = Colors.greenAccent[400]!;
const Color EXCEPTION_COLOR = Colors.red;
const String CLEAR_RESPONSE="cls";

//commands
const String TEST_COMMAND = "test";
const String HELP_COMMAND="help";
const String SIGN_UP_COMMAND = "signup";
const String SIGN_IN_COMMAND = "signin";
const String SIGN_OUT_COMMAND = "signout";
const String ACCESS_TYPE_COMMAND = "accesstype";
const String UPDATE_PASSWORD_COMMAND = "updatepwd";
const String RESET_PASSWORD = "resetpwd";
const String CURRENT_USER_COMMAND = "currentuser";

const String USER_PROFILE = "getprofile";
const String EDIT_PROFILE="editprofile";
const String CACHE_PROFILE="cache_profile";

const String ORGANIZATION_DATA_COMMAND = "getorgdata";
const String INVITE_ORGANISATION="invite_org";
const String CREATE_ORGANISATION="create_org";

const String TEAM_LIST = "getteamlist";
const String COACH_LIST = "getcoachlist";
const String ATHLETE_LIST = "getathletelist";
const String SENSOR_LIST = "getsensorlist";

const String ADD_TEAM = "add_team";
const String REMOVE_TEAM = "remove_team";

const String ADD_COACH = "add_coach";
const String REMOVE_COACH = "remove_coach";
const String ASSIGN_COACH = "assign_coach";
const String UNASSIGN_COACH = "unassign_coach";

const String ADD_ATHLETE = "add_athlete";
const String REMOVE_ATHLETE = "remove_athlete";
const String ASSIGN_ATHLETE = "assign_athlete";
const String UNASSIGN_ATHLETE = "unassign_athlete";

const String REGISTER_SENSOR = "register_sensor";
const String UNREGISTER_SENSOR = "unregister_sensor";
const String ASSIGN_SENSOR = "assign_sensor";
const String UNASSIGN_SENSOR = "unassign_sensor";
const String ASSIGNED_SENSOR="mysensor";

//collections
const String ATHLETES_COLLECTION = "Athletes";
const String COACH_COLLECTION = "Coach";
const String TEAM_COLLECTION = "Team";
const String ORGANIZATION_COLLECTION = "Organization";

const String LEDGER_COLLECTION = "Ledger";

const String INVITES_COLLECTION = "Invites";

const String SENSOR_COLLECTION = "Sensor";
const String FIRMWARE_COLLECTION = "Firmware";

const String UNIVERSAL_EVENT_COLLECTION = "UniversalEvent";
const String USER_EVENT_COLLECTION = "UserEvent";

const String GET_REPORT="get_report";
const String GET_MANAGER="get_manager";

const String CREATE_SESSION='add-session';
const String GET_SESSION_DATA="get-session-data";
const String VIEW_SESSION_DATA="view-session-data";