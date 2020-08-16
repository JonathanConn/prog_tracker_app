import 'package:flutter/material.dart';
import 'graph.dart';
import 'leaderboard.dart';
import 'clock.dart';

class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(
        title: ClockWidget(),
        actions: <Widget> [
          IconButton(
            icon: Icon(Icons.emoji_events), 
            onPressed: () {  print('icon selected\n'); },
                        
          )
        ],

      ),


      body: Container(
        color: Colors.red,
        child: Column(
           
           children: <Widget> [
            Expanded(
              child: 
              Container(  
                child: GaugeChart.withSampleData(),
              ),
            ),
            

             Expanded(
                            child: Container(               
                 color: Colors.yellow,
                 child: DataBaseListView(),
               ),
             )
           ],



        ) 

        ),

      );
        
  }

}








