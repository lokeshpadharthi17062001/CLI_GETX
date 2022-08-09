import 'package:conqur_backend_test/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class Emitter {
  static final Emitter _emitter = Emitter._internal();

  factory Emitter() {
    return _emitter;
  }

  Emitter._internal();

  final data = [].obs;

  void addCommand(String command) {
    data.add(Text(
      "> $command",
      style: TextStyle(color: COMMAND_COLOR, fontSize: FONT_SIZE),
    ));
    data.add(SizedBox(height: 10));
    // notifyListeners();
  }

  void addResponse(String response) {
    data.add(Text(
      response,
      style: TextStyle(color: RESPONSE_COLOR, fontSize: FONT_SIZE),
    ));
    data.add(SizedBox(height: 10));
  }

  void addResponseList(List response) {
    data.add(ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: response.length,
      itemBuilder: (context, index) {
        return Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              "$index : ${response[index].data().toString()}",
              style: TextStyle(color: RESPONSE_COLOR, fontSize: FONT_SIZE),
            ));
      },
    ));
    data.add(SizedBox(height: 10));
  }

  void addException(String response) {
    data.add(Text(
      response,
      style: TextStyle(color: EXCEPTION_COLOR, fontSize: FONT_SIZE),
    ));
    data.add(SizedBox(height: 10));
  }

  void removeResponse(){
    data.clear();
  }
}
