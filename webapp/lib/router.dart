import 'dart:html';

class Router {
  Map<String, Function> _routes;

  Router() {
    _routes = {};
  }

  void addHandler(String route, Function callback) {
    _routes[route] = callback;
  }

  void routeTo(String route) {
    _loadView(route);
  }

  void _loadView(String route) {
    if(_routes.containsKey(route)) {
      _routes[route]();
    }
  }

  void listen() {
    window.onPopState.listen((_) => _loadView(window.location.hash));
  }

}
