library controller;

import 'dart:async';

import 'logger.dart';
import 'platform.dart' as platform;
import 'view.dart' as view;

Logger log = new Logger('controller.dart');

void init() async {
  view.init();
  await platform.init();
}
