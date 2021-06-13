import 'dart:html';

import 'package:chatapp/utils.dart';

class Subject {
  final WebSocket socket;

  Subject(String username)
      : socket = WebSocket('ws://localhost:9090/ws?username=$username') {
    initListeners();
  }

  void initListeners() {
    socket.onOpen.listen((event) {
      print('Socket is open');
      send(serializeMsg(Actions.JoinChat, '', ''));
    });

    socket.onError.listen((Event event) {
      print('Socket erroed out: $event');
    });

    socket.onClose.listen((event) {
      print('Socket has closed');
    });
  }

  void send(String data) => socket.send(data);
  void close() => socket.close();
}
