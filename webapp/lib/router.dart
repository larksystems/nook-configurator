import 'dart:html';
import 'controller.dart' as controller;

class Route {
  String path;
  Function handler;

  Route(this.path, this.handler);
}

class Router {
  Map<String, Route> _routes;
  Route _authRoute;

  Router() {
    _routes = {};
  }

  void addHandler(Route route, {bool isAuthRoute = false}) {
    _routes[route.path] = route;
    if (isAuthRoute) {
      _authRoute = route;
    }
  }

  void listen() {
    window.onPopState.listen((PopStateEvent event) => _loadView(window.location.hash));
  }

  void routeTo(String path) {
    _loadView(path);
  }

  void _loadView(String path) {
    var targetRoute = _routes[path];
    if (targetRoute != null) {
      if (controller.signedInUser != null && targetRoute.path != _authRoute.path) {
        targetRoute.handler();
        window.location.hash = targetRoute.path;
      } else if (controller.signedInUser == null) {
        _authRoute.handler();
        window.location.hash = targetRoute.path;
      }
    }
  }
}
