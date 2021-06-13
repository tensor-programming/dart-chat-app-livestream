import 'dart:io';
import 'dart:convert';

import 'package:chatapp/session.dart';

void main() async {
  var port = 9090;

  var server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  var session = ChatSession();

  print('Server listening on port: $port');

  await for (HttpRequest request in server) {
    request.response.headers.add('Access-Control-Allow-Origin', '*');
    request.response.headers
        .add('Access-Control-Allow-Methods', 'POST,GET,DELETE,PUT,OPTIONS');

    switch (request.uri.path) {
      case '/signin':
        var payload = await utf8.decoder.bind(request).join();

        var username = Uri.splitQueryString(payload)['username'];

        if (username != null && username.isNotEmpty) {
          request.response.write(username);
        } else {
          request.response
            ..statusCode = 400
            ..write('Please provide a Username!');
        }

        await request.response.close();

        break;

      case '/ws':
        var username = request.uri.queryParameters['username']!;
        session.addUser(request, username);

        break;

      default:
        break;
    }
  }
}
