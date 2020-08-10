import 'navbar.dart';
import 'package:flutter/material.dart';

class LeaderboardPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp( 
      title: 'Leaderboard',
      home: Scaffold(
        body: Container(
          
        ),
        bottomNavigationBar: NavBarWidget(),
      ),

    );
  }
}

