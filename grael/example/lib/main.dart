import 'package:flutter/material.dart';
import 'package:grael/grael.dart';
import './model.dart';
import './routes.dart';

void main() {
  StateProvider.initializeState(
    (sl) async {
      /// these models are not just registered, but they are also provided
      /// via inherited widget. that's the reason behind the P
      await sl.registerLazySingletonP(() => MyData1());
      await sl.registerLazySingletonP(() => MyData2());
      await sl.registerLazySingletonP(() => MyData3());

      // you can also do your normal stuff with getIt
      // sl.registerLazySingleton(() => MyData4());
      sl.registerLazySingleton(() => MyData5());
    },
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return TMultiprovider(
        providers: [
          // Grael(create: (_) => MyData4()),
          TProvider(create: (_) => MyData4()),

          /// don't want to use sl.registerLazySinglitonP?
          /// No problem, you probably need to do something with the build context
          /// here it is:
          TProvider(create: (context) => StateProvider.getIt()<MyData5>()),

          // maybe you feel like doing this
          TProvider(
            create: (_) => SomeOtherModel(),
          )
        ],
        child: MaterialApp(
          title: 'Grael Statemanagement',
          routes: routes,
        ));
  }
}
