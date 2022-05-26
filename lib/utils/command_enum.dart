import 'package:conqur_backend_test/utils/constants.dart';

enum Command {
  test,
  signUp,
  signIn,
  currentUser,
  updatePassword,
  passwordResetLink,
  passwordReset,
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
      case CURRENT_USER_COMMAND:
        return Command.currentUser;
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
