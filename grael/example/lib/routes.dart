import 'package:flutter/material.dart';
import './pages/page_one.dart';
import './pages/page_two.dart';
import './pages/page_three.dart';

const String INVITE_LINK = '/app/invite';

var routes = {
  '/': (context) => MyHomePage(),
  '/page2': (context) => DemoPage2(),
  '/page3': (context) => DemoPage3(),
};
