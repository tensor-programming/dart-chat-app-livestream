import 'dart:io';
import 'dart:convert';

import 'package:chatapp/utils.dart';

class User {
  User({required this.session, required this.socket, this.name = ''});

  HttpSession session;
  WebSocket socket;
  String name;
}

class ChatSession {
  final List<User> _users = [];

  void addUser(HttpRequest req, String name) async {
    var ws = await WebSocketTransformer.upgrade(req);
    var user = User(
      session: req.session,
      socket: ws,
      name: name,
    );

    user.socket.listen((data) => _handleMsg(user, data),
        onError: (err) => print('Error on Websocket: $err'),
        onDone: () => _removeUser(user));

    _users.add(user);

    print('Added user: ${user.name}');
  }

  void _handleMsg(User user, data) {
    user.socket.add('${user.name} said: $data');
    Map<String, dynamic> decode = json.decode(data);
    var action = getAction(decode['type']);
    var msg = decode['data'];

    switch (action) {
      case Actions.JoinChat:
        user.socket.add(serializeMsg(
            Actions.JoinChat, '', 'Welcome to the chat, ${user.name}'));

        _broadcastMsg(Actions.JoinChat, user,
            '${user.name.toUpperCase()} has joined the chat');

        break;
      case Actions.ChatMsg:
        user.socket.add(serializeMsg(
          Actions.ChatMsg,
          'You',
          msg,
        ));

        _broadcastMsg(Actions.ChatMsg, user, msg);

        break;
      case Actions.LeaveChat:
        user.socket.close();
        break;
      case Actions.DefaultAction:
        break;
    }
  }

  void _removeUser(User user) {
    print('User left: ${user.name}');

    _users.removeWhere((c) => c.name == user.name);

    _broadcastMsg(Actions.LeaveChat, user,
        '${user.name.toUpperCase()} has left the chat!');
  }

  void _broadcastMsg(Actions action, User incoming, [String data = '']) {
    var from = action == Actions.JoinChat ? '' : incoming.name;

    _users
        .where((u) => u.name != incoming.name)
        .toList()
        .forEach((us) => us.socket.add(serializeMsg(action, from, data)));
  }
}
