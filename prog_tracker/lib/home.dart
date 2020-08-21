import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'graph.dart';
import 'leaderboard.dart';
import 'firebase.dart';
import 'clock.dart';
import 'package:flutter/cupertino.dart';

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
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.emoji_events),
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
      body: Container(
          color: Colors.red,
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  child: GaugeChart.withSampleData(),
                ),
              ),
              RaisedButton(
                onPressed: null,
                color: Colors.grey,
                child: Text(
                  "Start",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.yellow,
                  child: TasksListView(),
                ),
              )
            ],
          )),
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
                        Task t = new Task(
                            _name.text, _date, _selectedPriority.index);
                        Database.addTaskToUser(t);
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
