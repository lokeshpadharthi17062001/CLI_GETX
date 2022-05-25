import 'package:conqur_backend_test/utils/constants.dart';

enum Command{
  test,
  signUp,
  signIn,
  unknown
}

extension CommandParserExtension on String{

  Command get command{
    switch (this) {
      case TEST_COMMAND:
        return Command.test;
      case SIGN_UP_COMMAND:
        return Command.signUp;
      case SIGN_IN_COMMAND:
        return Command.signIn;
      default:
        return Command.unknown;
    }
  }

}