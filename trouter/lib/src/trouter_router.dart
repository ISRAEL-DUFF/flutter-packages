import 'package:flutter/material.dart';

/// Type Aliases
typedef BuilderFn = Widget Function(BuildContext);
typedef GuardFn = RouteGuard Function(String, dynamic);
typedef BootFn = Function(BuildContext, Uri?);
// typedef Map<String, dynamic> Json;

bool debugMode = false;

debugPrint(Object? object) {
  if (debugMode) print(object);
}

class TNavigator extends StatefulWidget {
  String? initialRoute;
  String? parentName;
  TRouter? rootRouter;
  List<BuilderFn>? history;
  TNavigator(
      {@required this.initialRoute,
      @required this.parentName,
      this.history,
      this.rootRouter});
  @override
  State<StatefulWidget> createState() {
    return _TNavigatorState();
  }
}

class _TNavigatorState extends State<TNavigator> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  initState() {
    super.initState();
    debugPrint(
        'CUSTOM ROUTER INIT ROUTE: ${widget.initialRoute}, ${widget.parentName}');
  }

  @override
  Widget build(BuildContext context) {
    Navigator nav;
    if (widget.history != null && widget.history!.isNotEmpty) {
      debugPrint('Navigator With History: ${widget.history}');
      nav = Navigator(
        key: _navigatorKey,
        initialRoute: widget.initialRoute,
        onGenerateInitialRoutes: (navigatorState, path) {
          List<Route<dynamic>> his = widget.history!
              .map((h) => MaterialPageRoute(
                    builder: h,
                    settings: RouteSettings(name: widget.parentName),
                  ))
              .toList();
          return his.toList();
        },
        onGenerateRoute: onGenerateRoute,
      );
    } else {
      debugPrint('Navigator with Route initialRoute: ${widget.initialRoute} ');
      nav = Navigator(
        key: _navigatorKey,
        initialRoute: widget.initialRoute,
        onGenerateRoute: onGenerateRoute,
      );
    }
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          if (_navigatorKey.currentState!.canPop()) {
            _navigatorKey.currentState!.pop();
            return false;
          }
          return true;
        },
        child: nav,
      ),
      // bottomNavigationBar: _yourBottomNavigationBar,
    );
  }

  Route onGenerateRoute(RouteSettings settings) {
    debugPrint('oGenerate Route Called: $settings');
    dynamic args = settings.arguments;
    // var routeArgs = {};
    // if (args != null) {
    //   routeArgs['data'] = args['data'];
    //   routeArgs['webdata'] = args['webdata'];
    // }
    // RouteSettings newSettings =
    //     RouteSettings(name: settings.name, arguments: routeArgs);

    RouteSettings newSettings =
        RouteSettings(name: settings.name, arguments: settings.arguments);

    TRoute? t = widget.rootRouter?.routingTable![settings.name];
    var builder;
    if (t != null) {
      builder = t.route();
    } else
      throw ('Invalid route ${settings.name}');

    return MaterialPageRoute(
      builder: builder,
      settings: newSettings,
    );
  }
}

class BootstrapPage extends StatefulWidget {
  Widget? initPage;
  Uri? initialRoute;
  Function(BuildContext, Uri?)? bootstrapFn;
  BootstrapPage(
      {Key? key,
      @required this.initPage,
      @required this.bootstrapFn,
      @required this.initialRoute})
      : super(key: key);
  @override
  _BootstrapPageState createState() => _BootstrapPageState();
}

class _BootstrapPageState extends State<BootstrapPage> {
  @override
  initState() {
    super.initState();
    widget.bootstrapFn!(context, widget.initialRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.initPage,
    );
  }
}

// DEFAULTS
defaultBootstrapFn(BuildContext context, Uri? uri) {}

class TRouter {
  Map<String, dynamic>? routes;
  Map<String, TRoute>? routingTable = {};
  String? initialRoute;
  Widget? bootStrapPage;
  final GlobalKey<NavigatorState> _rootNavigator = GlobalKey<NavigatorState>();
  BootFn? bootstrapFn;

  TRouter(
      {this.routes, this.bootStrapPage, this.initialRoute, this.bootstrapFn}) {
    _parseRoutes(routes: routes!, history: []);
    printRoutingTable();
  }

  printRoutingTable() {
    debugPrint('____Routing Table____');
    for (var l in routingTable!.entries) {
      debugPrint(l.value);
    }
  }

  get navigatorKey => _rootNavigator;

  // Map<String, Function(BuildContext)>
  void _parseRoutes(
      {@required Map<String, dynamic>? routes,
      String parentName = '/',
      @required List<String>? history,
      List<GuardFn>? guards}) {
    for (String r in routes!.keys) {
      if ((routes[r] is BuilderFn) || routes[r] is RouteRedirect) {
        // TODO: check for '/'
        List<String> h = [];
        h.addAll(history!);

        // take care of guards
        List<GuardFn> gs = [];
        if (guards != null) gs.addAll(guards);

        String pName = parentName;

        // make sure not to add parent name again to this (sub) root route
        if (r == '/') {
          pName = h.isEmpty ? '' : h.last;
        } else if (parentName != '/') {
          h.add(parentName);
        }

        // don't add '/' to root history
        if (parentName == '/' && r != '/') {
          h.add('/');
        }

        // form the routeName
        String nameKey = '';
        for (String s in h) {
          if (s != '/') nameKey = nameKey + s;
        }
        if (r == '/' && parentName != '/')
          nameKey = '$nameKey$parentName';
        else
          nameKey = '$nameKey$r';
        if (nameKey == '' && parentName == '/') {
          nameKey = '/';
        }

        routingTable![nameKey] = TRoute(
            builder: routes[r],
            isTrouter: r == '/',
            name: nameKey,
            parentName: pName,
            guards: gs,
            history: routes[r] is RouteRedirect
                ? [] // No history for RouteRedirect
                : h,
            rootRouter: this);
      } else if (routes[r] is Trouter) {
        List<GuardFn> gs = [];
        List<String> h = [];
        if (guards != null) {
          gs.addAll(guards);
        }
        if (routes[r].guard != null) {
          gs.add(routes[r].guard);
        }
        h.addAll(history!);
        h.add(parentName);
        _parseRoutes(
            routes: routes[r].routes, parentName: r, guards: gs, history: h);
      } else
        throw ('Error: failed to parse route $r');
    }
  }

  Route<dynamic> generateRoute(RouteSettings settings) {
    // TODO: parse the settings.name here
    var uri = Uri.parse(settings.name!);
    debugPrint(
        'settings = $settings, path = ${uri.path}, ${uri.queryParameters}');
    RouteSettings newSettings;
    if (uri.queryParameters.isEmpty) {
      newSettings =
          RouteSettings(name: uri.path, arguments: settings.arguments);
    } else {
      newSettings = RouteSettings(name: uri.path, arguments: {
        'query': uri.queryParameters,
        'body': settings.arguments
      });
    }

    debugPrint('ROUTE SEttings: $newSettings');

    TRoute? t = routingTable![uri.path];
    var builder;
    if (t != null) {
      builder = t.route(routeArguments: uri.queryParameters);
    } else
      throw ('Invalid route ${uri.path}');

    return MaterialPageRoute(
      builder: builder,
      settings: newSettings,
    );
  }

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return generateRoute(settings);
  }

  List<Route> onGenerateInitialRoute(String initRoute) {
    debugPrint('initialRoute: $initialRoute, $initRoute');

    // NOTE: the [initRoute] is the route used to launch the app
    // the [initialRoute] is initial route provided to TRouter
    // [initRoute] takes higher precedence over [initialRoute]
    String initialR = initRoute;
    // initialRoute == null ? '/' : initialRoute;

    Widget? initialPage = bootStrapPage == null ? Container() : bootStrapPage;
    BootFn? initFn = bootstrapFn == null ? defaultBootstrapFn : bootstrapFn;

    // TODO: parse the initialRoute here
    var uri = Uri.parse(initialR);
    print(uri.path);
    uri.queryParameters.forEach((k, v) {
      debugPrint('key: $k - value: $v');
    });
    return [
      MaterialPageRoute(
        builder: (context) => BootstrapPage(
          bootstrapFn: initFn,
          initPage: initialPage,
          initialRoute: uri,
        ),
        settings: RouteSettings(name: uri.path, arguments: uri.queryParameters),
      )
    ];
  }

  Future<dynamic> pushNamed(String routeName, {dynamic arguments}) {
    RouteSettings settings =
        RouteSettings(name: routeName, arguments: arguments);
    return _rootNavigator.currentState!
        .pushNamed(routeName, arguments: settings);
  }
}

class Trouter {
  String? initialRoute;
  Map<String, dynamic>? routes; // Map<String, Function(BuildContext)> routes;

  /// Guards this route base on certain conditions
  /// this callback is executed by the routing system when the route is accessed
  /// this [guard] is called with two params: the [path] trying to accessed and it's [arguments]
  GuardFn? guard;
  List<BuilderFn> history = [];

  Trouter({@required this.initialRoute, @required this.routes, this.guard});
}

class RouteGuard {
  bool? allow;
  dynamic redirectTo;
  dynamic arguments;

  RouteGuard({@required this.allow, this.redirectTo, this.arguments}) {
    if (redirectTo != null) {
      if (!(redirectTo is BuilderFn) && !(redirectTo is String)) {
        throw ('Error: Supply a String or Builder Fn for redirectTo');
      }
    }
    if (redirectTo is String) {
      // create a route redirect with path string
      redirectTo = RouteRedirect(to: redirectTo, arguments: arguments);
    }
  }

  static RouteGuard execute(
      {@required String? name,
      @required List<GuardFn>? guards,
      @required routingTable,
      dynamic routeArguments}) {
    if (guards != null && guards.length > 0) {
      for (var g in guards) {
        RouteGuard r = g(name!, routeArguments);
        if (!r.allow!) {
          if (r.redirectTo is RouteRedirect) {
            return RouteGuard(
                allow: false, redirectTo: r.redirectTo.resolve(routingTable));
          } else {
            return RouteGuard(allow: false, redirectTo: r.redirectTo);
          }
        }
      }
    }
    return RouteGuard(allow: true);
  }
}

class TRoute {
  TRouter? rootRouter;
  bool? isTrouter; // indicate if this a sub(Navigator)route
  dynamic builder;
  String? name;
  String? parentName;
  List<GuardFn>? guards;
  List<String>? history;
  TRoute({
    @required this.name,
    @required this.builder,
    @required this.rootRouter,
    this.isTrouter = false,
    this.parentName,
    this.guards,
    this.history,
  });

  @override
  String toString() {
    return ''' 
        ******** $name ********
        parentName: $parentName
        builder: $builder
        guards: $guards
        history: $history
      ******************************
    ''';
  }

  BuilderFn route({dynamic routeArguments}) {
    // TODO: implement route here
    if (builder == null) throw ('Invalide builder for $name');
    if ((builder is BuilderFn)) {
      // is this route guarded?
      RouteGuard r = RouteGuard.execute(
          guards: guards,
          name: name,
          routingTable: rootRouter!.routingTable,
          routeArguments: routeArguments);
      if (!r.allow!) return r.redirectTo;

      debugPrint('ROUTING for:......... ${name}');
      if (isTrouter!) {
        return (context) => TNavigator(
            rootRouter: rootRouter,
            initialRoute: name,
            history: _buildHistory(routeArguments: routeArguments),
            parentName: parentName);
      } else {
        return builder;
      }
    } else if (builder is RouteRedirect) {
      return builder.resolve(rootRouter!.routingTable);
    } else
      throw ('Bad Builder for $name');
  }

  List<Widget Function(BuildContext)> _buildHistory({dynamic routeArguments}) {
    List<BuilderFn> h = [];
    debugPrint('Resolving History: $history');
    String path = '';
    for (String r in history!) {
      path = path == '/' ? r : '$path$r';
      dynamic b = rootRouter!.routingTable![path];
      if (b == null || b is! TRoute) throw ('Invalide History $path');
      if (b.builder is BuilderFn) {
        RouteGuard r = RouteGuard.execute(
            guards: b.guards,
            name: name,
            routingTable: rootRouter!.routingTable,
            routeArguments: routeArguments);
        if (!r.allow!) return [r.redirectTo];
        h.add(b.builder);
      } else if (b.builder is RouteRedirect) {
        dynamic a = b.builder.resolve(rootRouter!.routingTable);
        h.add(a);
      }
    }
    h.add(builder); // TODO: make sure this is 'builder'
    return h;
  }
}

class RouteRedirect {
  String? to;
  dynamic arguments;
  RouteRedirect({@required this.to, this.arguments});

  @override
  String toString() {
    // TODO: implement toString
    return '''RouteRedirect (to: $to, arguments: $arguments)''';
  }

  BuilderFn resolve(Map<String, dynamic> routingTable) {
    debugPrint('Resolving Redirect: $this');
    dynamic b = routingTable[to];
    if (b == null || !(b is TRoute))
      throw ('Error: Invalide redirect for ${to}');
    if (b.builder is BuilderFn) {
      RouteGuard r = RouteGuard.execute(
          guards: b.guards,
          name: to,
          routingTable: routingTable,
          routeArguments: arguments);
      if (!r.allow!) return r.redirectTo;
      return b.builder;
    }
    if (b.builder is RouteRedirect) return b.builder.resolve(routingTable);
    throw ('Error: unknown builder $b');
  }
}
