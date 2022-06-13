import 'package:conqur_backend_test/utils/enum.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppData {
  static final AppData _AppData = AppData._internal();

  factory AppData() {
    return _AppData;
  }

  AppData._internal();

  User? user;
  String? org_id;
  AccessType? accessType;
}
