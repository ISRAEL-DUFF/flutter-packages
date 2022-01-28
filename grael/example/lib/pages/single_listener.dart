// import 'package:flutter/material.dart';
// import '../inherited_widgets/provider.dart';
// import '../model.dart';
// import 'dart:math';

// class DemoSingleListener extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     var data1 = TProvider.of<MyData1>(context)!;
//     var data2 = TProvider.of<MyData2>(context)!;

//     // Single listeners
//     return Column(
//       children: [
//         Text('******** Single Listener ******'),
//         TListenableBuilder<MyData1>(
//             value: data1,
//             builder: (context, data, _) {
//               print('REBUILDING single 1');

//               return Container(
//                   child: Row(
//                 children: [
//                   ElevatedButton(
//                       onPressed: () {
//                         int a = Random().nextInt(500);
//                         data.updateA(a);
//                       },
//                       child: Text('Update 2')),
//                   Text('Data 2: ${data.a}'),
//                 ],
//               ));
//             }),
//         TListenableBuilder<MyData2>(
//             value: data2,
//             builder: (context, data, _) {
//               print('REBUILDING single 2');

//               return Container(
//                   child: Row(
//                 children: [
//                   ElevatedButton(
//                       onPressed: () {
//                         int a = Random().nextInt(500);
//                         data.updateName('String: ' + a.toString());
//                       },
//                       child: Text('Update 3')),
//                   Text('Data 3: ${data.c}'),
//                 ],
//               ));
//             }),
//         Text('******** End Single******'),
//       ],
//     );
//   }
// }
