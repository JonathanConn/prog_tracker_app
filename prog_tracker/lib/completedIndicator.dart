import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class completedBar extends StatefulWidget {
  completedBar({Key key}) : super(key: key);

  @override
  _completedBarState createState() => _completedBarState();
}

class _completedBarState extends State<completedBar> {
  @override
  Widget build(BuildContext context) {
    return LinearPercentIndicator(
      width: 300,
      lineHeight: 20,
      percent: 0.5,
      animation: true,
      animationDuration: 500,
      backgroundColor: Colors.white,
      progressColor: Colors.green,
    );
  }
}
