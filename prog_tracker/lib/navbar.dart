import 'leaderboard.dart';
import 'login.dart';
import 'profile.dart';

import 'package:flutter/material.dart';

class NavBarWidget extends StatefulWidget {
  @override
  _NavBarWidgetState createState() => _NavBarWidgetState();
}

class _NavBarWidgetState extends State<NavBarWidget> {
  int _selectedIndex = 0;
  final routes = [
    LeaderboardPage(),
    Container(color: Colors.red,),
    LandingPage(),
  ];
  
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: routes[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar (
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Score'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            title: Text('Profile'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),

    );
    
  }
}
