import 'package:flutter/material.dart';
import 'package:grael/grael.dart';
import 'dart:math';

class BaseModel extends TDataNotifier {
  int id = 1;
  String label = 'C';

  randomUpdate() {
    id = Random().nextInt(500);
    notifyListeners();
  }
}

class MyData1 extends BaseModel {
  int a = 1;
  int b = 2;
  String c = 'C';
  int id = 1;

  updateA(int newA) {
    a = newA;
    // updateState();
    notifyListeners();
  }

  randomUpdate() {
    id = Random().nextInt(500);
    notifyListeners();
  }
}

class MyData2 extends BaseModel {
  int nuum = 1;
  String c = 'C';

  updateName(String name) {
    c = name;
    // updateState();
    notifyListeners();
  }
}

class SomeModel extends BaseModel {
  int id = 1;
  String label = 'C';

  randomUpdate() {
    id = Random().nextInt(500);
    notifyListeners();
  }
}

class SomeOtherModel extends ChangeNotifier {
  int id = 1;
  randomUpdate() {
    id = Random().nextInt(500);
    notifyListeners();
  }
}

class AccountInfo extends BaseModel {
  int staffId = 0;
  String accountNum = 'ACCT';
  String accountName = '';
  int balance = 200;

  setName(String name) {
    accountName = name;
    // notifyListeners();
  }

  setAccount(String n) {
    accountNum = n;
    notifyListeners();
  }
}

class MyData3 extends BaseModel {
  num data2 = 5;
}

class MyData4 extends BaseModel {}

class MyData5 extends BaseModel {}

class MyData6 extends BaseModel {}
