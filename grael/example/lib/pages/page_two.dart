import 'package:flutter/material.dart';
import 'package:grael/grael.dart';
import '../model.dart';
import 'dart:math';

class DemoPage2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('DEMO PAGE 2');
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Column(children: [
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popAndPushNamed('/');
                },
                child: Text('Goto Page 1')),
            SizedBox(height: 50),
            Row(
              children: [
                ElevatedButton(
                    onPressed: () {
                      context.reset<MyData1>();
                    },
                    child: Text('Reset MyData1')),
                ElevatedButton(
                    onPressed: () {
                      context.reset<MyData2>();
                    },
                    child: Text('Reset MyData2'))
              ],
            ),
            SizedBox(height: 50),
            TMultiListenableBuilder(
                values: [
                  context.value<MyData1>(),
                  context.value<MyData2>(),
                ],
                builder: (context, _, __) {
                  MyData1 d = context.find<MyData1>()!;
                  MyData2 d2 = context.find<MyData2>()!;
                  print('BUILDING MultiList 1');

                  return Column(
                    children: [
                      Row(
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                d.randomUpdate();
                              },
                              child: Text('Update MyData1')),
                          Text(' : ${d.id}')
                        ],
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                d2.randomUpdate();
                              },
                              child: Text('Update MyData2')),
                          Text(' : ${d2.id}')
                        ],
                      )
                    ],
                  );
                }),
            const SizedBox(
              height: 30,
            ),
            TMultiListenableBuilder(
                values: [
                  context.value<SomeOtherModel>(),
                  context.value<MyData3>(),
                ],
                builder: (context, _, __) {
                  print('BUILDING MultiList 2');
                  var d = context.find<SomeOtherModel>()!;
                  var d3 = context.find<MyData3>()!;
                  return Column(
                    children: [
                      Row(
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                d.randomUpdate();
                              },
                              child: const Text('SomeOtherModel')),
                          Text(' : ${d.id}')
                        ],
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                d3.randomUpdate();
                              },
                              child: const Text('Update MyData3')),
                          Text(' : ${d3.id}')
                        ],
                      )
                    ],
                  );
                }),
            const SizedBox(
              height: 20,
            ),
            TMultiListenableBuilder(
                values: [
                  context.value<MyData1>(),
                  context.value<MyData2>(),
                  context.value<MyData3>(),
                ],
                builder: (context, _, __) {
                  print('BUILDING MultiList 3');
                  var d = context.find<MyData1>()!;
                  var d2 = context.find<MyData2>()!;
                  var d3 = context.find<MyData3>()!;
                  return Column(
                    children: [
                      Row(
                        children: [
                          const Text('My Data1: '),
                          Text(' : ${d.id}')
                        ],
                      ),
                      Row(
                        children: [
                          const Text('My Data2: '),
                          Text(' : ${d2.id}')
                        ],
                      ),
                      Row(
                        children: [
                          const Text('MyData3: '),
                          Text(' : ${d3.id}')
                        ],
                      )
                    ],
                  );
                })
          ]),
        ),
      ),
    );
  }
}
