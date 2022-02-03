import 'package:flutter/material.dart';
import 'package:grael/grael.dart';
import '../model.dart';

class DemoPage3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('PAGE THREE (3)');
    var p = ValueNotifier(6);
    var p2 = ValueNotifier("Some string");
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/');
              },
              child: const Text('Goto Page 1')),
          const Center(child: Text('Testing Inhrited widget')),
          Row(
            children: [
              ElevatedButton(
                  onPressed: () {
                    context.reset<MyData1>();
                  },
                  child: const Text('Reset Data 1')),
              ElevatedButton(
                  onPressed: () {
                    context.resetAll();
                  },
                  child: const Text('Reset All'))
            ],
          ),
          MultiListenableBuilder(
              values: [
                context.value<SomeOtherModel>(),
                context.value<MyData3>(),

                TListenable<AccountInfo>(
                  value: AccountInfo(),
                ),
                TListenable<SomeModel>(
                  value: SomeModel(),
                ),
                TListenable<SomeOtherModel>(),

                /// You can also use value notifier if you wish
                context.value(value: p),
                context.value(value: p2)
              ],
              builder: (BuildContext context, value1, value2, value3, value4,
                  value5, value6, value7, Widget child) {
                print('BUILDING MultiList 2');

                return Column(
                  children: [
                    Row(
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              value1.randomUpdate();
                            },
                            child: const Text('SomeOtherModel')),
                        Text(' : ${value1.id}')
                      ],
                    ),
                    Row(
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              value2.randomUpdate();
                            },
                            child: const Text('Update MyData3')),
                        Text(' : ${value2.id}')
                      ],
                    ),
                    Row(
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              value4.randomUpdate();
                            },
                            child: const Text('Update SomeModel')),
                        Text(' : ${value4.id}')
                      ],
                    )
                  ],
                );
              })
        ],
      ),
    );
  }
}
