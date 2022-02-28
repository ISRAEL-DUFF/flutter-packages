import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trouter/trouter.dart';

const String INVITE_LINK = '/app/invite';

TRouter myRouter = TRouter(routes: {
  // '/': RouteRedirect(to: '/app'),
  '/': (context) => TestPage(n: 0),
  // '/page1': (context) => RouteRedirect(to: '/'),
  '/page2': (context) => TestPage(n: 2),
  '/onboard': (context) => TestPage(n: 49),
  '/auth': Trouter(
      initialRoute: '/',
      guard: (path, arguments) {
        if (arguments == null) {
          return RouteGuard(allow: true);
        } else {
          return RouteGuard(allow: false, redirectTo: '/app');
        }
      },
      routes: {
        // '/': RouteRedirect(to: '/auth/login'),
        '/': (context) => TestPage(n: 48),
        '/register': (context) => TestPage(n: 50),
        '/login': (context) => TestPage(n: 51),
        '/otp': (context) => TestPage(n: 52),
        '/forgotpassword': (context) => TestPage(n: 53),
        '/newpassword': (context) => TestPage(n: 54)
      }),
  '/app': Trouter(
      initialRoute: '/',
      guard: (path, args) {
        if (args != null) {
          return RouteGuard(allow: true);
        } else {
          // for example:
          // return RouteGuard(allow: false, redirectTo: (context) => LoginPage());
          // OR
          // return RouteGuard(allow: false, redirectTo: '/auth/login');
          if (path == INVITE_LINK) {
            return RouteGuard(
                allow: false, redirectTo: '/auth/register', arguments: args);
          } else
            return RouteGuard(allow: false, redirectTo: '/auth/login');
        }
      },
      routes: {
        '/': (context) => TestPage(n: 70),
        '/profile': (context) => TestPage(n: 71),
        '/notification': (context) => TestPage(n: 72),
        '/invite': (context) => TestPage(n: 73), // TODO: fix this
        '/test': Trouter(initialRoute: '/', routes: {
          '/': (context) => TestPage(),
          '/p1': (context) => TestPage(n: 1),
          '/p2': (context) => TestPage(n: 2),
          '/p3': (context) => TestPage(n: 3),
          '/p4': Trouter(initialRoute: '/', routes: {
            '/': (context) => TestPage(n: 4),
            '/p5': (context) => TestPage(n: 5),
            '/p6': (context) => TestPage(n: 6),
            '/p7': Trouter(initialRoute: '/', routes: {
              '/': (context) => TestPage(n: 7),
              '/p8': (context) => TestPage(n: 8),
              '/p9': (context) => TestPage(n: 9)
            })
          }),
        })
      }),
}, bootStrapPage: TestPage());

// This function executes when the app Just launches
class TestPage extends StatelessWidget {
  int n;
  TextEditingController controller = TextEditingController();
  TestPage({this.n = 0});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text('Test Page ${n}'),
      TextField(
        controller: controller,
      ),
      Row(
        children: [
          ElevatedButton(
              onPressed: () {
                print('Pushing: ${controller.text}');
                // Navigator.pushNamed(context, controller.text);
                myRouter.pushNamed(controller.text);
              },
              child: const Text('Push Named')),
          ElevatedButton(
              onPressed: () {
                print('Using Pushing: ${controller.text}');
                myRouter.pushNamedAndRemoveUntil(controller.text, (route) {
                  return false;
                });
              },
              child: const Text('Push Named and Remove'))
        ],
      )
    ])));
  }
}
