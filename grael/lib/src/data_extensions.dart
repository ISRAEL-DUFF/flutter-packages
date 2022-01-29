import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'dart:async';
import './provider.dart';
import './state_provider.dart';

class TDependencyNotifier<T extends Object> {
  void Function<R extends Object>(BuildContext) onReset;
  TDataNotifier dataNotifier;
  TDependencyNotifier({required this.dataNotifier, required this.onReset});

  reset(BuildContext context) {
    onReset<T>(context);
  }
}

// extension on TProvider
extension StateExtension<T> on TProviderState<T> {}

Create<R> crate<R extends Object>(GetIt sl) {
  return (BuildContext context) {
    return sl.get<R>();
  };
}

extension GetItExtension on GetIt {
  static List<Widget> tProviders = [];
  static Map<Type, TDependencyNotifier> dependencyNotifiers = {};
  registerLazySingletonP<T extends ChangeNotifier>(T Function() factoryFunc,
      {String? instanceName, FutureOr<dynamic> Function(T)? dispose}) async {
    /// Register the lazy singliton with GetIt
    registerLazySingleton(factoryFunc,
        instanceName: instanceName, dispose: dispose);

    /// store listeners to notify when GetIt resets this object of type T
    registerAnewType<T>();

    // create a provider for this type T
    Widget w = TProvider(create: crate<T>(GetIt.instance));
    tProviders.add(w);
  }

  registerSingletonP<T extends ChangeNotifier>(T instance,
      {String? instanceName,
      bool? signalsReady,
      FutureOr<dynamic> Function(T)? dispose}) {
    registerSingleton(instance,
        instanceName: instanceName,
        signalsReady: signalsReady,
        dispose: dispose);
    Widget w = TProvider(create: crate<T>(GetIt.instance));
    // Widget w = Grael(create: crate<T>(GetIt.instance));
    tProviders.add(w);
  }

  static registerAnewType<T extends Object>() {
    // store listeners to notify when this object resets
    if (dependencyNotifiers[T] == null) {
      dependencyNotifiers[T] = TDependencyNotifier(
          dataNotifier: TDataNotifier(),
          onReset: <P extends Object>(context) {
            context.reset<T>();
          });
    }
  }
}

// extension on BuildContext
extension StateOnContext on BuildContext {
  T? find<T>() {
    return TProvider.of<T>(this);
  }

  TProviderState tWState<T>() {
    return TProvider.fo<T>(this)!;
  }

  /// Resets a given type R to it's default value
  reset<R extends Object>() {
    if (tGetIt().isRegistered<R>()) {
      tGetIt().resetLazySingleton<R>();
      tGetIt().allReady().then((f) {
        tWState<R>().rebuild();
        tUpdateListeners<R>();
      });
    } else {
      /// type wasn't registered with GetIt, find it and rebuild
      R? v = find<R>();
      if (v != null) {
        tWState<R>().rebuild();
        tUpdateListeners<R>();
      }
    }
  }

  /// Resets All registered and Provided states
  /// This feature only reset (and not unregister) all GetIt lazySinglitons
  /// It also resets all provided states.
  /// i.e calls create functions of each provider again
  resetAll() async {
    for (TDependencyNotifier d in GetItExtension.dependencyNotifiers.values) {
      d.reset(this);
    }
  }

  GetIt tGetIt() {
    return StateProvider.getIt();
  }

  List<Widget> tGetItProviders() {
    return GetItExtension.tProviders;
  }

  tUpdateListeners<R extends Object>() {
    GetItExtension.dependencyNotifiers[R]?.dataNotifier.updateValue();
  }

  TDataNotifier tDataListenable<R extends Object>() {
    return GetItExtension.dependencyNotifiers[R]!.dataNotifier;
  }

  TListenable<T> value<T extends ChangeNotifier>({T? value}) {
    return TListenable(value: value);
  }
}
