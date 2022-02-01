import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'mixins.dart';
import './data_extensions.dart';

// debug
bool debugMode = true;
debugPrint(Object? object) {
  if (debugMode) print(object);
}

typedef Create<R> = R Function(BuildContext context);

/// A wrapper widget arround TProvider widget
/// This widget simply creates a key (when non is given) for the TProvider
class Grael<T extends ChangeNotifier> extends StatelessWidget {
  Widget? child;
  Create<T> create;
  Key? gkey;
  Grael({Key? key, required this.create, this.child}) {
    gkey = key ?? GlobalKey<TProviderState>();
  }

  @override
  Widget build(BuildContext context) {
    return TProvider(key: gkey, create: create, child: child);
  }
}

/// The baseline wrapper widget for Inherited widget TInheritedWidget
class TProvider<T extends ChangeNotifier> extends StatefulWidget {
  Widget? child;
  Create<T> create;

  static List<Widget> allProviders = [];
  TProvider({Key? key, required this.create, this.child}) : super(key: key) {
    allProviders.add(this);
    GetItExtension.registerAnewType<T>();
  }

  @override
  TProviderState createState() => TProviderState<T>();

  static TProviderState? fo<P>(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<TInheritedWidget<P>>()!
        .state;
  }

  static P? of<P>(BuildContext context) {
    return fo<P>(context)!.data;
  }
}

class TProviderState<T> extends State<TProvider> {
  T? data;
  TDataNotifier notifier = TDataNotifier();
  int? _currentBuildValue;
  TProviderState();

  @override
  void initState() {
    super.initState();
    data = widget.create(context) as T;
    _currentBuildValue = notifier.value;
  }

  @override
  void didChangeDependencies() {
    // change dependencies here
    _currentBuildValue = notifier.value;
    debugPrint('TProvider Dependency changed: $_currentBuildValue');

    // finally call super
    super.didChangeDependencies();
  }

  rebuild() {
    setState(() {
      data = widget.create(context) as T;
      notifier.updateValue();
    });
  }

  @override
  Widget build(BuildContext context) =>
      TInheritedWidget(child: widget.child, data: data, state: this);
}

/// The inherited widget used in TProvider
/// This widget has a minimal interface
class TInheritedWidget<T> extends InheritedWidget {
  final T? data;
  final TProviderState? state;
  TInheritedWidget({
    Key? key,
    this.state,
    @required Widget? child,
    this.data,
  }) : super(key: key, child: child!);

  @override
  bool updateShouldNotify(TInheritedWidget oldWidget) {
    if (data == oldWidget.data) {
      debugPrint('Update should NOT Notify Descendants');
      return false;
    } else {
      debugPrint('Update IS Notifying inherited descendants ');
      return true;
    }
  }
}

/// A wrapper widget for multiple TProviders
/// this widget combines all widgets (from GetIt and also the ones)
/// given via the [providers] field
class TMultiprovider extends StatelessWidget {
  final Widget? child;
  List<Widget>? providers = [];
  final List<Widget> allProvides = [];
  TMultiprovider({Key? key, this.child, this.providers}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> provs = context.tGetItProviders();
    allProvides.addAll(providers!);
    allProvides.addAll(provs);
    return _buildTree(context);
  }

  TProvider _buildTree(BuildContext context, {int i = 0}) {
    if (allProvides.isEmpty) return TProvider(create: (_) => TDataNotifier());

    Widget p = allProvides[i];
    TProvider? tp;
    if (p is TProvider) {
      tp = p;
    } else if (p is Grael) {
      tp = p.build(context) as TProvider;
    } else {
      throw ('Type $p is not a $TProvider');
    }

    if (i < allProvides.length - 1) {
      tp.child = _buildTree(context, i: i + 1);
      return tp;
    } else {
      tp.child = child!;
      return tp;
    }
  }
}

class TDataNotifier extends ValueNotifier<int> {
  TDataNotifier() : super(Random().nextInt(500));
  updateValue({int? v}) {
    if (v == null) {
      value = Random().nextInt(500);
    } else {
      value = v;
    }
  }
}

//
// class TListenableBuilder<T extends TDataNotifier> extends StatelessWidget {
//   final Widget Function(BuildContext, T, Widget?) builder;
//   Widget? child;
//   T value;
//   TListenableBuilder(
//       {Key? key, required this.value, required this.builder, this.child})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<int>(
//         valueListenable: value,
//         child: child,
//         builder: (context, v, child) {
//           return builder(context, value, child);
//         });
//   }
// }

// MULTIPLE Listenable
class TListenable<T extends ChangeNotifier> with TypeCheck {
  T? value;
  bool valueIsFromProvider = false;
  TListenable({this.value}) {
    if (!isSubtype<T, ChangeNotifier>()) {
      throw ('Type $T must be a subtype of $ChangeNotifier');
    }

    if (hasNoValue) valueIsFromProvider = true;
  }

  void getValueFromProvider(BuildContext context) {
    value = TProvider.of<T>(context);
    if (value == null) {
      throw ('No Provider value found for $T');
    }
  }

  bool get hasNoValue {
    if (value == null) {
      return true;
    } else {
      return false;
    }
  }

  bool get hasValue {
    return !hasNoValue;
  }

  bool get shouldGetValueFromProvider {
    return hasNoValue || valueIsFromProvider;
  }

  addListener({void Function()? onUpdate, void Function()? onReset}) {
    debugPrint('Adding Listener for $T');
    if (hasValue) {
      if (onUpdate != null) {
        value!.addListener(onUpdate);
      }

      if (onReset != null) {
        GetItExtension.dependencyNotifiers[T]?.dataNotifier
            .addListener(onReset);
      }
    }
  }

  removeListener({void Function()? onUpdate, void Function()? onReset}) {
    debugPrint('Removing Listener for $T');

    if (hasValue) {
      if (onUpdate != null) {
        value!.removeListener(onUpdate);
      }

      if (onReset != null) {
        GetItExtension.dependencyNotifiers[T]?.dataNotifier
            .removeListener(onReset);
      }
    }
  }
}

///
class TMultiListenableBuilder extends StatefulWidget {
  final Widget Function(
      BuildContext, T? Function<T extends ChangeNotifier>(), Widget?) builder;
  final Widget? child;
  final List<TListenable> values;
  const TMultiListenableBuilder(
      {Key? key, required this.values, required this.builder, this.child})
      : super(key: key);
  @override
  TMultiListenableBuilderState createState() => TMultiListenableBuilderState();
}

class TMultiListenableBuilderState extends State<TMultiListenableBuilder>
    with TypeCheck {
  bool initialized = false;
  List<TListenable>? values;
  int buildValue = Random().nextInt(500);

  @override
  void initState() {
    super.initState();
    values = widget.values;
  }

  @override
  void didChangeDependencies() {
    debugPrint('buildValue: $buildValue ... Dependency changed');

    // change dependencies here
    if (!initialized) {
      initListeners();
    }

    // finally call super
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    unsubscribeFromEvents();
    debugPrint('buildValue: $buildValue ... Widget State Disposed');
  }

  void unsubscribeFromEvents() {
    debugPrint('buildValue: $buildValue ... Unsubscribing');
    for (TListenable l in values!) {
      l.removeListener(onUpdate: listenForUpdate, onReset: listenForRebuild);
    }
  }

  void subscribeToEvents([resubscription = false]) {
    debugPrint('buildValue: $buildValue ... Subscribing');
    for (TListenable l in values!) {
      if (l.shouldGetValueFromProvider) {
        l.getValueFromProvider(context);
      }
      l.addListener(onUpdate: listenForUpdate, onReset: listenForRebuild);
    }
  }

  initListeners([bool watchRebuild = false]) {
    // listen for individual changes in listeners
    subscribeToEvents();
    initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return _buildTree();
  }

  Widget _buildTree({int i = 0}) {
    if (i < values!.length - 1) {
      return Builder(builder: (context) {
        return _buildTree(i: i + 1);
      });
    } else {
      return Builder(builder: (context) {
        return widget.builder(context, find, widget.child);
      });
    }
  }

  listenForUpdate() {
    debugPrint('buildValue: $buildValue ... Updated');
    if (mounted) setState(() {});
  }

  listenForRebuild() {
    debugPrint('buildValue: $buildValue ... Rebuilding');

    /// unsubscribe from the old object
    unsubscribeFromEvents();

    /// resubscribe by setting this to 'false'
    /// the resubscription will be taken care of in [didChangeDependencies()]
    initialized = false;
  }

  T? find<T extends ChangeNotifier>() {
    for (TListenable l in values!) {
      if (l.value is T) {
        return l.value as T;
      }
    }
  }
}

/// Experimental
/// this is also TMultiListenableBuilder, but one that uses a dynamic function
/// for it's builder parameter.
/// Note: this tries to mimic Provider's builder function
class MultiListenableBuilder extends StatefulWidget {
  final Function builder;
  final Widget? child;
  final List<TListenable> values;
  const MultiListenableBuilder(
      {Key? key, required this.values, required this.builder, this.child})
      : super(key: key);
  @override
  MultiListenableBuilderState createState() => MultiListenableBuilderState();
}

class MultiListenableBuilderState extends State<MultiListenableBuilder>
    with TypeCheck {
  bool initialized = false;

  /// List of listenable values.
  /// Note: A listenable value is any Subtype of [ChangeNotifier] OR [ValueNotifier]
  /// [TListenable] is just a wrapper arround the listenable type
  List<TListenable>? values;
  int buildValue = Random().nextInt(500);

  /// The Builder Function.
  /// The function is dynamic in that no param list or return type specified.
  /// The arguments list is store in the [builderArgs] field
  /// The order of the arguments or parameters is as follows
  /// [builder(BuildContext context, T1, T2, T3,...,Tn, Widget child)]
  late Function builder;
  var builderArgs = [];

  @override
  void initState() {
    super.initState();
    values = widget.values;
    builder = widget.builder;
  }

  @override
  void didUpdateWidget(MultiListenableBuilder oldWidget) {
    print('widget UPDated');
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    debugPrint('buildValue: $buildValue ... Dependency changed');

    // change dependencies here
    if (!initialized) {
      initListeners();
    }

    // finally call super
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    unsubscribeFromEvents();
    debugPrint('buildValue: $buildValue ... Widget State Disposed');
  }

  /// Remove old listeners when dependencies change.
  /// This method also resets the [builderArgs] list.
  void unsubscribeFromEvents() {
    debugPrint('buildValue: $buildValue ... Unsubscribing');
    for (TListenable l in values!) {
      l.removeListener(onUpdate: listenForUpdate, onReset: listenForRebuild);
    }

    /// reset the builderArgs list
    builderArgs = [];
  }

  /// Add listeners to the [TListenable] so it can be notified of changes within the listener
  /// This method also populates the [builderArgs] list, setting the first param to be a
  /// [BuildContext] and then setting intermediate values to be [TListenable]s
  /// then finally sets last param to be a child [Widget]
  void subscribeToEvents([resubscription = false]) {
    debugPrint('buildValue: $buildValue ... Subscribing');

    /// make 1st arg a BuildContext
    builderArgs.add(context);

    for (TListenable l in values!) {
      if (l.shouldGetValueFromProvider) {
        l.getValueFromProvider(context);
      }
      l.addListener(onUpdate: listenForUpdate, onReset: listenForRebuild);

      /// set intermediate params to be [TListenable]
      builderArgs.add(l.value);
    }

    /// finally, make the last arg the child widget
    builderArgs.add(widget.child);
  }

  initListeners([bool watchRebuild = false]) {
    // listen for individual changes in listeners
    subscribeToEvents();
    initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return _buildTree();
  }

  Widget _buildTree({int i = 0}) {
    if (i < values!.length - 1) {
      return Builder(builder: (context) {
        return _buildTree(i: i + 1);
      });
    } else {
      return Builder(builder: (context) {
        var w = Function.apply(builder, builderArgs);
        if (w is Widget) {
          return w;
        } else {
          throw ('$w is not a Widget');
        }
      });
    }
  }

  listenForUpdate() {
    debugPrint('buildValue: $buildValue ... Updated');
    if (mounted) setState(() {});
  }

  listenForRebuild() {
    debugPrint('buildValue: $buildValue ... Rebuilding');

    /// unsubscribe from the old object
    unsubscribeFromEvents();

    /// resubscribe by setting this to 'false'
    /// the resubscription will be taken care of in [didChangeDependencies()]
    initialized = false;
  }
}
