import 'package:flutter/material.dart';
import 'package:grael/grael.dart';
import '../model.dart';

import './multi_listener.dart';

class DemoPage3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('PAGE THREE (3)');
    var p = ValueNotifier(6);
    var p2 = ValueNotifier("Some string");
    return Scaffold(
      // appBar: AppBar(title: Text('Cashly App')),
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
              builder: (context, prov1, prov2, prov3, prov4, prov5, prov6,
                  prov7, _) {
                print('BUILDING MultiList 2');

                return Column(
                  children: [
                    Row(
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              prov1.randomUpdate();
                            },
                            child: const Text('SomeOtherModel')),
                        Text(' : ${prov1.id}')
                      ],
                    ),
                    Row(
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              prov2.randomUpdate();
                            },
                            child: const Text('Update MyData3')),
                        Text(' : ${prov2.id}')
                      ],
                    ),
                    Row(
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              prov4.randomUpdate();
                            },
                            child: const Text('Update SomeModel')),
                        Text(' : ${prov4.id}')
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
