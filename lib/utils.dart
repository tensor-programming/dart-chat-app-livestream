import 'dart:convert';

enum Actions {
  JoinChat,
  ChatMsg,
  LeaveChat,
  DefaultAction,
}

String serializeMsg(Actions type, String from, String msg) => json.encode({
      'type': type.toString(),
      'from': from,
      'data': msg,
    });

Map<String, dynamic> deserializeMsg(String msg) {
  var decode = json.decode(msg);

  return {
    'type': getAction(decode['type']),
    'from': decode['from'],
    'data': decode['data']
  };
}

Actions getAction(String type) {
  return Actions.values.firstWhere((element) => element.toString() == type);
}
