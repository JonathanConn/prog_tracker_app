import 'package:flutter/material.dart';
import 'navbar.dart';
import 'themes.dart';

void main() {
  runApp(MaterialApp(
      theme: globalDarkTheme(),
      home: Scaffold(
        bottomNavigationBar: NavBarWidget(),
        body: Container(),
      )));
}

// TODO: add daily streak counter, break day earned every # days completed
