import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class ClockWidget extends StatefulWidget {
  ClockWidget({Key key}) : super(key: key);

  @override
  _ClockWidgetState createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> {
  String _timeString;
  Timer _timer;

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
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
    super.initState();
  }
    
  @override
  Widget build(BuildContext context) {
    return Text(_timeString);
    
  }
  @override 
  void dispose() { // prevents memory leak because setState gets held
    _timer.cancel();
    super.dispose();
  }
}