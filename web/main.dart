import 'dart:html';

import 'views/signin.dart';
import 'views/room.dart';

import './router.dart';

void main() {
  router
    ..register('/', (_) => SignInView())
    ..register('/chat-room', (params) => RoomView(params))
    ..goToView('/');
}
