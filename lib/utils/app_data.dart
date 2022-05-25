import 'package:firebase_auth/firebase_auth.dart';

class AppData {
  static final AppData _AppData = AppData._internal();

  factory AppData() {
    return _AppData;
  }

  AppData._internal();

  late UserCredential user;
}
