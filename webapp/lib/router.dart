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
    if (targetRoute == null) {
      _defaultRoute.handler(); // this needs adding in the same was as we add _authRoute, should point to the dashboard page
      window.location.hash = _defaultRoute.path;
      return;
    }
    if (controller.signedInUser == null) {
      _authRoute.handler();
      window.location.hash = targetRoute.path; // shouldn't this be _authRoute.path ?
      return;
    }
    targetRoute.handler();
    window.location.hash = targetRoute.path;
  }
}
