import './views/view.dart';

typedef ViewInstanceFn = View Function(Map data);

class Router {
  final List<Map<String, ViewInstanceFn>> _routes;

  Router() : _routes = [];

  void register(String path, ViewInstanceFn fn) {
    _routes.add({path: fn});
  }

  void goToView(String path, {Map? params}) {
    var fn = _routes.firstWhere(
        (Map<String, ViewInstanceFn> route) => route.containsKey(path),
        orElse: () => {})[path];

    fn!(params ?? {});
  }
}

Router router = Router();
