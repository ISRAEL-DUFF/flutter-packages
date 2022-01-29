import 'package:flutter/material.dart';
import 'package:grael/grael.dart';
import '../model.dart';
import 'dart:math';

class DemoMultiListener extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var p = ValueNotifier(5);
    // Multiple listeners
    return TMultiListenableBuilder(
        values: [
          /// this is same as: value = TProvider.of<MyData1>(context)
          /// OR: value = context.find<MyData1>()
          TListenable<MyData1>(),
          TListenable<MyData2>(),

          /// You can also explicitely specify value
          TListenable<AccountInfo>(
            value: AccountInfo(),
          ),
          TListenable<SomeModel>(
            value: SomeModel(),
          ),
          TListenable<SomeOtherModel>(),

          /// You can also use value notifier if you wish
          context.value(value: p)
        ],
        builder: (context, find, _) {
          /// the [find] fn works same as context.find except that it can only
          /// find values you are currently listening on
          /// NOTE: if all the values you are listening on are already provided,
          /// then ignore the find and use context.find instead
          AccountInfo accountInfo = find<AccountInfo>()!;
          SomeModel someModel = find<SomeModel>()!;

          // OR find values you provided globally
          MyData1? l1 = context.find<MyData1>();
          MyData2? d2 = context.find<MyData2>()!;
          SomeOtherModel someOtherModel = context.find<SomeOtherModel>()!;

          return Center(
            child: Column(
              children: [
                Text('******** Multiple Builder ******'),
                Container(
                    child: Row(
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          l1!.randomUpdate();
                        },
                        child: Text('Update 1 ')),
                    Text(' Data 1: ${l1!.id}'),
                  ],
                )),
                Container(
                    child: Row(
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          d2.randomUpdate();
                        },
                        child: Text('Update 2 ')),
                    Text(' Data 4: ${d2.id}'),
                  ],
                )),
                Container(
                    child: Row(
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          int a = Random().nextInt(500);
                          accountInfo.setAccount('ACCT-' + a.toString());
                          p.value = Random().nextInt(500);
                        },
                        child: Text('Change ACCT')),
                    Text(
                        'Account Number: ${accountInfo.accountNum}, P: ${p.value}'),
                  ],
                )),
                Container(
                    child: Column(
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          someModel.randomUpdate();
                          someOtherModel.randomUpdate();
                        },
                        child: Text('Random Update')),
                    Row(
                      children: [
                        Text(
                            '    Some Model ID: ${someModel.id}, OtherModel ID: ${someOtherModel.id} '),
                        // Text('Account Number: ${}'),
                      ],
                    ),
                  ],
                )),
                Text('******** End Multiple ******'),
              ],
            ),
          );
        });
  }
}
