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
  Route _defaultRoute;

  Router() {
    _routes = {};
  }

  void addAuthHandler(Route route) {
    _routes[route.path] = route;
    _authRoute = route;
  }

  void addDefaultHandler(Route route) {
    _routes[route.path] = route;
    _defaultRoute = route;
  }

  void addHandler(Route route) {
    _routes[route.path] = route;
  }

  void listen() {
    window.onPopState.listen((PopStateEvent event) => _loadView(window.location.hash));
  }

  void routeTo(String path) {
    _loadView(path);
  }

  void _loadView(String path) {
    var targetRoute = _routes[path];
    if (controller.signedInUser == null) {
      targetRoute = _authRoute;
    }
    if (controller.signedInUser != null && targetRoute == _authRoute) {
      targetRoute = _defaultRoute;
    }
    if (targetRoute == null) {
      targetRoute = _defaultRoute;
    }
    targetRoute.handler();
    window.location.hash = targetRoute.path;
  }
}
