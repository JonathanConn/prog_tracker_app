import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'graph.dart';
import 'leaderboard.dart';
import 'firebase.dart';
import 'clock.dart';
import 'completedIndicator.dart';
import 'package:flutter/cupertino.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: new Text(new DateFormat('EEEE M/d').format(DateTime.now())),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                print('icon selected\n');
              },
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TaskForm()),
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
                child: Column(
              children: [
                new Padding(padding: EdgeInsets.all(20)),
                new Padding(
                  padding: EdgeInsets.all(30),
                  child: new TimeWidget(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    completedBar(),
                  ],
                ),
              ],
            )),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(15),
                child: NotCompletedTasksListView(),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(15),
                child: CompletedTasksListView(),
              ),
            ),
          ],
        )

        // Column(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: <Widget>[

        //     Expanded(
        //       child: Container(
        //         child: Row(
        //           mainAxisAlignment: MainAxisAlignment.center,
        //           children: [
        //             completedBar(),
        //           ],
        //         ),
        //         color: Colors.pink,
        //       ),
        //     ),
        //     // Expanded(child: TasksListView().NotCompletedList()),
        //     // Expanded(child: TasksListView().CompletedList()),
        //   ],
        // ),
        );
  }
}

class TaskForm extends StatefulWidget {
  TaskForm({Key key}) : super(key: key);

  @override
  _TaskFormState createState() => _TaskFormState();
}

enum PriorityRadio { low, med, high }

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _name = new TextEditingController();
  DateTime _date = new DateTime.now();

  PriorityRadio _selectedPriority = PriorityRadio.med;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text("New Task"),
      ),
      body: Center(
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _name,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(labelText: "Name"),
                  ),
                  Container(
                    height: 200,
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.dateAndTime,
                      initialDateTime: DateTime(1969, 1, 1, 11, 33),
                      onDateTimeChanged: (DateTime newDateTime) {
                        _date = newDateTime;
                      },
                      use24hFormat: false,
                      minuteInterval: 1,
                    ),
                  ),
                  ListTile(
                    title: new Text("Low"),
                    leading: Radio(
                      value: PriorityRadio.low,
                      groupValue: _selectedPriority,
                      onChanged: (PriorityRadio value) {
                        setState(() {
                          _selectedPriority = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: new Text("Med"),
                    leading: Radio(
                      value: PriorityRadio.med,
                      groupValue: _selectedPriority,
                      onChanged: (PriorityRadio value) {
                        setState(() {
                          _selectedPriority = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: new Text("High"),
                    leading: Radio(
                      value: PriorityRadio.high,
                      groupValue: _selectedPriority,
                      onChanged: (PriorityRadio value) {
                        setState(() {
                          _selectedPriority = value;
                        });
                      },
                    ),
                  ),
                  RaisedButton(
                      child: Text('Create task'),
                      onPressed: () async {
                        _formKey.currentState.save();
                        Task t = new Task(_name.text, Timestamp.fromDate(_date),
                            _selectedPriority.index);
                        Database.addTask(t);
                        Navigator.pop(context);
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
