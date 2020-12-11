import 'dart:html';
import 'controller.dart' as controller;

class Route {
  String path;
  Map<String, String> params;
  Function handler;

  Route(this.path, this.handler, [this.params]) {
    if (params == null) params = {};
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
    window.onPopState.listen((_) => routeTo(window.location.hash));
  }

  Map<String, String> get routeParams => _currentRoute.params;
  void routeTo(String path) {
    if (controller.signedInUser == null) {
      _setRouteAndLoad(_authRoute);
      return;
    }
    if (controller.signedInUser != null && _currentRoute == _authRoute) {
      _setRouteAndLoad(_defaultRoute);
      return;
    }
    var pathUri = Uri.parse(path);
    // Check if there's a query after the fragment and process it, it seems that traditional URIs don't suppor this.
    if (pathUri.fragment.contains('?')) {
      var tuple = pathUri.fragment.split('?');
      pathUri = pathUri.replace(
        fragment: tuple[0],
        query: tuple[1]
      );
    }
    var desiredRoute = _routes['#${pathUri.fragment}'];
    if (desiredRoute == null) {
      _setRouteAndLoad(_defaultRoute);
      return;
    }
    if (pathUri.hasQuery) {
      desiredRoute.params = pathUri.queryParameters;
      desiredRoute.path = '${desiredRoute.path.split('?')[0]}?${pathUri.query}';
    }
    _setRouteAndLoad(desiredRoute);
  }

  void _setRouteAndLoad(Route route) {
    _currentRoute = route;
    window.location.hash = _currentRoute.path;
    _currentRoute.handler();
  }
}
