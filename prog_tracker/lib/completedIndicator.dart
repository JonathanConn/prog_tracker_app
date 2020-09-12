import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'firebase.dart';

class completedBar extends StatefulWidget {
  completedBar({Key key}) : super(key: key);

  @override
  _completedBarState createState() => _completedBarState();
}

class _completedBarState extends State<completedBar> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Database.getTasksCompletedRatio(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return new LinearPercentIndicator(
              width: 350,
              lineHeight: 30,
              percent: snapshot.data == 0.0 ? 0.05 : snapshot.data,
              animation: true,
              animationDuration: 500,
              backgroundColor: Colors.white,
              progressColor: Colors.green,
            );
          } else if (snapshot.hasError) {
            return new Text("error");
          } else {
            return new Text("Sign in first");
          }
        });
  }
}
