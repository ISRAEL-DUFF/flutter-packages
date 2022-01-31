import 'package:flutter/material.dart';
import 'package:grael/grael.dart';
import '../model.dart';
import 'dart:math';

// import './page_one.dart';
import './single_listener.dart';
import './multi_listener.dart';

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var data1 = TProvider.of<MyData1>(context)!;
    var data2 = TProvider.of<MyData2>(context)!;
    print('HOME PAGE');
    return Scaffold(
      // appBar: AppBar(title: Text('Cashly App')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).popAndPushNamed('/page2');
              },
              child: const Text('Goto Page 2')),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/page3');
              },
              child: const Text('Goto Page 3')),
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
          DemoMultiListener(),
          // PlayState(),
          // DemoSingleListener()
        ],
      ),
    );
  }
}

// class PlayState extends StatefulWidget {
//   Widget? child;
//   PlayState({
//     Key? key,
//   }) : super(key: key);
//   @override
//   PlayStateS createState() => PlayStateS();
// }

// class PlayStateS extends State<PlayState> {
//   @override
//   Widget build(BuildContext context) {
//     print('REBUILDING PLAYSTATE');
//     return Column(children: [
//       TListenableBuilder<MyData1>(
//           value: MyData1(),
//           builder: (context, data, _) {
//             return Column(
//               children: [
//                 Text('******** Play State******'),
//                 Container(
//                     child: Row(
//                   children: [
//                     ElevatedButton(
//                         onPressed: () {
//                           int a = Random().nextInt(500);
//                           data.updateA(a);
//                         },
//                         child: Text('Update 2')),
//                     Text('PlayState Data 1: ${data.a}'),
//                   ],
//                 )),
//                 Text('******** End PlayState ******'),
//               ],
//             );
//           })
//     ]);
//   }
// }
