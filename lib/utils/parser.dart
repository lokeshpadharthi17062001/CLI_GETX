class CommandParser {
  parse(String? command) {
    List<String> splitted = command!.split(' ');
    if (splitted[0] == "test") {
      return splitted[1];
    }
    else{
      throw "UNKNOWN COMMAND";
    }
  }
}
