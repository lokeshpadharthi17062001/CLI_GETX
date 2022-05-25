import 'package:conqur_backend_test/utils/constants.dart';
import 'package:flutter/cupertino.dart';

class Emitter extends ChangeNotifier {
  static final Emitter _emitter = Emitter._internal();

  factory Emitter() {
    return _emitter;
  }

  Emitter._internal();

  final List<Widget> data = [];

  void addCommand(String command) {
    data.add(Text(
      "> $command",
      style: TextStyle(color: COMMAND_COLOR, fontSize: FONT_SIZE),
    ));
    data.add(SizedBox(height: 10));
    notifyListeners();
  }

  void addResponse(String response) {
    data.add(Text(
      response,
      style: TextStyle(color: RESPONSE_COLOR, fontSize: FONT_SIZE),
    ));
    data.add(SizedBox(height: 10));
    notifyListeners();
  }

  void addException(String response) {
    data.add(Text(
      response,
      style: TextStyle(color: EXCEPTION_COLOR, fontSize: FONT_SIZE),
    ));
    data.add(SizedBox(height: 10));
    notifyListeners();
  }
}
