import 'dart:html';
import 'controller.dart' as controller;

class Route {
  String path;
  Map<String, String> params;
  Function handler;

  Route(this.path, this.handler, [this.params]) {
    if (params == null) params = {};
  }

  void processParams(String paramsString) {
    for (var param in paramsString.split('&')) {
      var paramParts = param.split('=');
      params[paramParts[0]] = Uri.decodeComponent(paramParts[1]);
    }
  }
}

class Router {
  Map<String, Route> _routes;
  Route _authRoute;
  Route _defaultRoute;
  Route _currentRoute;

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
    window.onPopState.listen((_) => _loadView(window.location.hash));
  }

  void routeTo(String path) {
    _loadView(path);
  }

  Map<String, String> get routeParams => _currentRoute.params;

  void _loadView(String path) {
    var pathParts = path.split('?');
    _currentRoute = _routes[pathParts[0]];
    if (controller.signedInUser == null) {
      _currentRoute = _authRoute;
    }
    if (controller.signedInUser != null && _currentRoute == _authRoute) {
      _currentRoute = _defaultRoute;
    }
    if (_currentRoute == null) {
      _currentRoute = _defaultRoute;
    }
    if (pathParts.length > 1) {
      _currentRoute.processParams(pathParts[1]);
    }
    window.location.hash = _currentRoute.path;
    _currentRoute.handler();
  }
}
