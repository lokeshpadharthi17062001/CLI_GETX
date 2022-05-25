import 'package:conqur_backend_test/utils/constants.dart';
import 'package:conqur_backend_test/utils/emitter.dart';
import 'package:conqur_backend_test/utils/parser.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CLI extends StatefulWidget {
  CLI({Key? key}) : super(key: key);

  @override
  State<CLI> createState() => _CLIState();
}

class _CLIState extends State<CLI> {
  TextEditingController commandInputController = TextEditingController();
  FocusNode commandInputFocusNode = FocusNode();

  late Emitter responseEmitter;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    responseEmitter = context.watch<Emitter>();
    return Scaffold(
      body: Container(
          child: Column(
        children: [
          Expanded(
              child: Container(
            padding: EdgeInsets.all(10),
            color: Colors.black,
            child: ListView.builder(
              itemCount: responseEmitter.data.length,
              itemBuilder: (context, index) {
                return responseEmitter.data[index];
              },
            ),
          )),
          Row(
            children: [
              Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Icon(Icons.arrow_forward_ios_sharp, size: 14)),
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
                  onPressed: () => sendCommand(),
                  child: Text(
                    "SEND",
                    style: TextStyle(color: Colors.black),
                  ))
            ],
          )
        ],
      )),
    );
  }

  sendCommand() {
    commandInputFocusNode.requestFocus();
    responseEmitter.addCommand(commandInputController.value.text);
    try {
      CommandParser().parse(commandInputController.value.text).then((response) {
        if(response != "" && response != null){
          responseEmitter.addResponse(response.toString());
        }
      });
    } catch (e) {
      responseEmitter.addException(e.toString());
    }
  }
}
