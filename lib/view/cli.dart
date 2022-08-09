import 'package:cloud_functions/cloud_functions.dart';
import 'package:get/get.dart';
import 'package:conqur_backend_test/plot.dart';
import 'package:conqur_backend_test/utils/constants.dart';
import 'package:conqur_backend_test/utils/emitter.dart';
import 'package:conqur_backend_test/utils/parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class CLI extends StatefulWidget {
  CLI({Key? key}) : super(key: key);

  @override
  State<CLI> createState() => _CLIState();
}

class _CLIState extends State<CLI> {
  TextEditingController commandInputController = TextEditingController();
  FocusNode commandInputFocusNode = FocusNode();
  ScrollController listScrollController = ScrollController();
  var debug_information = false.obs;
  late Emitter responseEmitter;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    responseEmitter = Emitter();
    return Scaffold(
      body: Container(
          child: Obx(() => Column(
            children: [
              Expanded(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    color: Colors.black,
                    child: ListView.builder(
                      controller: listScrollController,
                      itemCount: responseEmitter.data.length,
                      itemBuilder: (context, index) {
                        return responseEmitter.data[index];
                      },
                    ),
                  )),
              Row(
                children: [
                  if (debug_information.value)
                    Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_forward_ios_sharp,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            debug_information.value = !debug_information.value;
                          },
                        ))
                  else
                    Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_forward_ios_sharp,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            debug_information.value = !debug_information.value;
                          },
                        )),
                  Expanded(
                      child: Container(
                        child: TextField(
                          style: TextStyle(color: Colors.black, fontSize: FONT_SIZE),
                          autofocus: true,
                          focusNode: commandInputFocusNode,
                          onSubmitted: (value) => sendCommand(),
                          controller: commandInputController,
                          decoration: InputDecoration(
                            hintStyle:
                            TextStyle(color: Colors.grey, fontSize: FONT_SIZE),
                            border: InputBorder.none,
                            hintText: 'enter command here',
                          ),
                        ),
                      )),
                  TextButton(
                      onPressed: () => commandInputController.clear(),
                      child: Text(
                        "CLEAR",
                        style: TextStyle(color: Colors.black),
                      )),
                  TextButton(
                      onPressed: () => sendCommand(),
                      child: Text(
                        "SEND",
                        style: TextStyle(color: Colors.black),
                      ))
                ],
              )
            ],
          ))
      ),
    );
  }

  sendCommand() async {
    commandInputFocusNode.requestFocus();
    responseEmitter.addCommand(commandInputController.value.text);
    try {
      CommandParser()
          .parse(commandInputController.value.text)
          .then((response) async {
        if (response != "" && response != null && !debug_information.value) {
          if (response is List) {
            responseEmitter.addResponseList(response);
          } else {
            responseEmitter.addResponse(response.toString());
          }
          await align_response(listScrollController);
        }
      });
      if (commandInputController.value.text.split(' ')[0] ==
          'view-session-data') {
        var plot_data = await FirebaseFunctions.instance
            .httpsCallable('get_session_data')
            .call({
          'session_id': commandInputController.value.text.split(' ')[1]
        });
        Get.to(() => Sync(plot_data.data));
      }
      if (commandInputController.value.text == "cls") {
        responseEmitter.removeResponse();
        commandInputController.clear();
      }
    } catch (e) {
      responseEmitter.addException(e.toString());
      align_response(listScrollController);
    }
  }
}

align_response(listScrollController) async {
  await Future.delayed(const Duration(milliseconds: 300));
  SchedulerBinding.instance.addPostFrameCallback((_) {
    listScrollController.animateTo(
        listScrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 500),
        curve: Curves.linear);
  });
}
