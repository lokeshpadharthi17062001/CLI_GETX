import 'package:flutter/material.dart';

//font size
const double FONT_SIZE = 16;

//colors
const Color RESPONSE_COLOR = Colors.white;
Color COMMAND_COLOR = Colors.greenAccent[400]!;
const Color EXCEPTION_COLOR = Colors.red;

//commands
const String TEST_COMMAND = "test";
const String SIGN_UP_COMMAND = "signup";
const String SIGN_IN_COMMAND = "signin";
const String SIGN_OUT_COMMAND = "signout";
const String ACCESS_TYPE_COMMAND = "accesstype";
const String UPDATE_PASSWORD_COMMAND = "updatepwd";
const String RESET_PASSWORD_LINK_COMMAND = "resetpwdlink";
const String RESET_PASSWORD_COMMAND = "resetpwd";
const String CURRENT_USER_COMMAND = "currentuser";
const String ORGANIZATION_DATA_COMMAND = "getorgdata";
const String USER_PROFILE = "getprofile";

//org commands
const String ORG_TEAM_LIST = "getteamlist";
const String ORG_COACH_LIST = "getcoachlist";
const String ORG_ATHLETE_LIST = "getathletelist";
const String ORG_SENSOR_LIST = "getsensorlist";

//collections
const String ATHLETE_COLLECTION = "Athlete";
const String COACH_COLLECTION = "Coach";
const String TEAM_COLLECTION = "Team";
const String ORGANIZATION_COLLECTION = "Organization";

const String LEDGER_COLLECTION = "Ledger";

const String INVITES_COLLECTION = "Invites";

const String SENSOR_COLLECTION = "Sensor";
const String FIRMWARE_COLLECTION = "Firmware";

const String UNIVERSAL_EVENT_COLLECTION = "UniversalEvent";
const String USER_EVENT_COLLECTION = "UserEvent";
