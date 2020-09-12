import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class TimeWidget extends StatefulWidget {
  TimeWidget({Key key}) : super(key: key);

  @override
  _TimeWidgetState createState() => _TimeWidgetState();
}

class _TimeWidgetState extends State<TimeWidget> {
  String _timeString;
  Timer _timer;

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('hh:mm:ss').format(dateTime);
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
    return Text(
      _timeString,
      style: Theme.of(context).textTheme.headline3,
    );
  }

  @override
  void dispose() {
    // prevents memory leak because setState gets held
    _timer.cancel();
    super.dispose();
  }
}
