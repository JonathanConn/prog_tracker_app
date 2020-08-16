import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'graph.dart';

class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _timeString; 

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MM/dd/yyyy hh:mm:ss').format(dateTime);
  }
  
  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);
    setState(() {
      _timeString = formattedDateTime;
    });
  }

  @override
  void initState() {
    _timeString = _formatDateTime(DateTime.now());
    Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: Text(_timeString),
        actions: <Widget> [
          IconButton(
            icon: Icon(Icons.emoji_events), 
            onPressed: () {  print('icon selected\n'); },
                        
          )

        ],

      ),


      body: GaugeChart.withSampleData(),

    );
    
  }

}


