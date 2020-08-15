import 'navbar.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {

  runApp(
    MaterialApp( 
      home: Scaffold(
        bottomNavigationBar: NavBarWidget(),
        body: Container(color: Colors.yellow,),
      )
    )
  );
}
