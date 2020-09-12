import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:prog_tracker/home.dart';
import 'themes.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn();
final FirebaseAuth _auth = FirebaseAuth.instance;

FirebaseUser _user;
String _userID;

class LoginAuth {
  static void _setUser() async {
    _user = await _auth.currentUser();
    _userID = _user.uid.toString();
  }

  static Future<FirebaseUser> getUser() async {
    return await _auth.currentUser();
  }

  static Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      _user = null;
      _userID = null;
    } catch (e) {
      print(e); // TODO: show dialog with error
    }
  }

  static Future<void> signInAnonymously() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
    } catch (e) {
      print(e);
    }
  }

  static Future<FirebaseUser> signInGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final FirebaseUser user =
        (await _auth.signInWithCredential(credential)).user;
    Database.addUserToDatabase(user);
    _setUser();
    return user;
  }

  static Future<FirebaseUser> handleSignInEmail(
      String _email, String _password) async {
    AuthResult result = await _auth.signInWithEmailAndPassword(
        email: _email.trim(), password: _password.trim());
    final FirebaseUser user = result.user;

    assert(user != null);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);
    _setUser();
    return user;
  }

  static Future<FirebaseUser> handleSignUp(
      String _email, String _password) async {
    AuthResult result = await _auth.createUserWithEmailAndPassword(
        email: _email.trim(), password: _password.trim());
    final FirebaseUser user = result.user;

    assert(user != null);
    assert(await user.getIdToken() != null);

    Database.addUserToDatabase(user);
    _setUser();
    return user;
  }
}

class Task {
/*
Timestamp to DateTime => 
DateTime t = time.toDate();

DateTime to TimeStamp =>
Timestamp t = Timestamp.fromDate(time);
*/
  String name, description;
  int timeSpent, priority;
  Timestamp startDate, endDate, createdDate, dueDate;
  bool completed;

  Task(String name, Timestamp dueDate, int priority) {
    this.name = name;
    this.description = "";
    this.dueDate = dueDate;
    this.priority = priority;

    this.createdDate = Timestamp.now();

    this.startDate =
        Timestamp.now(); // default so we dont pass null into firebase
    this.endDate =
        Timestamp.now(); // default so we dont pass null into firebase

    this.completed = false;
    this.timeSpent = 0;
    this.priority = 0;
  }

  Task.copy(
      String name,
      String description,
      int timeSpent,
      int priority,
      Timestamp startDate,
      Timestamp endDate,
      Timestamp createdDate,
      Timestamp dueDate,
      bool completed) {
    this.name = name;
    this.description = description;
    this.dueDate = dueDate;
    this.priority = priority;
    this.createdDate = createdDate;
    this.startDate = startDate;
    this.endDate = endDate;
    this.completed = completed;
    this.timeSpent = timeSpent;
    this.priority = priority;
  }

  Task.clone(Task _oldTask) {
    this.name = _oldTask.name;
    this.description = _oldTask.description;
    this.dueDate = _oldTask.dueDate;
    this.priority = _oldTask.priority;
    this.createdDate = _oldTask.createdDate;
    this.startDate = _oldTask.startDate;
    this.endDate = _oldTask.endDate;
    this.completed = _oldTask.completed;
    this.timeSpent = _oldTask.timeSpent;
    this.priority = _oldTask.priority;
  }
}

// TODO: streak class stored as user subcollection

class Database {
  static Future<bool> checkUser(FirebaseUser _user) async {
    try {
      var collectionRef = Firestore.instance.collection("users");
      var doc = await collectionRef.document(_user.uid).get();
      return doc.exists;
    } catch (e) {
      print(e);
    }
  }

  static void addUserToDatabase(FirebaseUser _user) async {
    if (await checkUser(_user)) {
      Firestore.instance.collection("users").document(_user.uid).setData({
        "name": _user.uid.toString(),
        "age": "",
        "school": "",
        "year": 0,
        "degree": "",
        "score": 0,
      }, merge: false // merge true overrites data
          );
    }
  }

  // adds to current signed in user
  static void addTask(Task _task) async {
    if (await checkUser(_user)) {
      Firestore.instance
          .collection("users")
          .document(_user.uid)
          .collection("tasks")
          .document("${_task.name}")
          .setData({
        "name": _task.name,
        "dueDate": _task.dueDate,
        "timeSpent": _task.timeSpent,
        "completed": _task.completed,
        "createdDate": _task.createdDate,
        "startDate": _task.startDate,
        "endDate": _task.endDate,
        "priority": _task.priority
      }, merge: false); //will not overwrite
    }
    if (await checkUser(_user)) {
      Firestore.instance
          .collection("users")
          .document(_user.uid)
          .collection("tasks")
          .document("${_task.name}")
          .setData({
        "name": _task.name,
        "dueDate": _task.dueDate,
        "timeSpent": _task.timeSpent,
        "completed": _task.completed,
        "createdDate": _task.createdDate,
        "startDate": _task.startDate,
        "endDate": _task.endDate,
        "priority": _task.priority
      }, merge: false); //will not overwrite
    }
  }

  static void setTask(Task _oldTask, Task _newTask) async {
    if (await checkUser(_user)) {
      // Add new info
      Firestore.instance
          .collection("users")
          .document(_user.uid)
          .collection("tasks")
          .document("${_newTask.name}")
          .setData({
        "name": _newTask.name ?? _oldTask.name,
        "dueDate": _newTask.dueDate,
        "timeSpent": _newTask.timeSpent,
        "completed": _newTask.completed,
        "createdDate": _newTask.createdDate,
        "startDate": _newTask.startDate,
        "endDate": _newTask.endDate,
        "priority": _newTask.priority
      }, merge: true); //will overwrite

      if (_oldTask.name != _newTask.name) {
        // remove old info
        Firestore.instance
            .collection("users")
            .document(_user.uid)
            .collection("tasks")
            .document("${_oldTask.name}")
            .delete();
      }
    }
  }

  // finds task in db of user and returns task obj
  static Future<Task> getTask(String _taskName) async {
    if (await checkUser(_user)) {
      Firestore.instance
          .collection("users")
          .document(_user.uid)
          .collection("tasks")
          .document("$_taskName")
          .get()
          .then((val) {
        print("VALUE ${val.data}");
        if (val.exists) {
          return buildTaskFromDocSnap(val);
        } else {
          print("task not found");
        }
      });
    }
    return null;
  }

  static void completeTask(String _taskName) async {
    if (await checkUser(_user)) {
      try {
        Firestore.instance
            .collection("users")
            .document(_user.uid)
            .collection("tasks")
            .document("$_taskName")
            .updateData(
          {"completed": true},
        );
      } catch (e) {
        print(e);
      }
    } else {
      print("USER NOT FOUND");
    }
  }

  static Task buildTaskFromDocSnap(DocumentSnapshot val) {
    return Task.copy(
        val["name"],
        val["description"],
        val["timeSpent"],
        val["priority"],
        val["startDate"],
        val["endDate"],
        val["createdDate"],
        val["dueDate"],
        val["completed"]);
  }

  static Future<double> getTasksCompletedRatio() async {
    if (_user != null) {
      if (await checkUser(_user)) {
        return await Firestore.instance
            .collection("users")
            .document(_user.uid)
            .collection("tasks")
            .getDocuments()
            .then((val) {
          int total = 0, completed = 0;
          val.documents.forEach((task) {
            total += 1;
            if (task["completed"] == true) completed += 1;
          });
          return completed / total;
        });
      }
    }
  }
}

class NotCompletedTasksListView extends StatelessWidget {
  Icon getPriorityIcon(int _priority) {
    List<Icon> _priorityIcons = [
      Icon(
        Icons.lens,
        color: Colors.green,
      ),
      Icon(
        Icons.lens,
        color: Colors.yellow,
      ),
      Icon(
        Icons.lens,
        color: Colors.red,
      ),
    ];
    if (_priority >= 0 && _priority < _priorityIcons.length) {
      return _priorityIcons[_priority];
    } else {
      return _priorityIcons[0]; //default
    }
  }

  @override
  Widget build(BuildContext context) {
    return (() {
      if (_userID == null) {
        return new Text("Sign in first plz");
      } else {
        return new StreamBuilder(
          stream: Firestore.instance
              .collection("users")
              .document(_userID)
              .collection("tasks")
              .where("completed", isEqualTo: false)
              .orderBy("priority", descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
            if (snapshot.data == null) return new Text("No tasks :)");

            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return new Text('Loading...');
              default:
                List<Widget> tiles = snapshot.data.documents
                    .map<Widget>((DocumentSnapshot value) {
                  // get task obj from each doc in snapshot
                  Task t = Database.buildTaskFromDocSnap(value);

                  return Container(
                    child: Column(
                      children: [
                        Container(
                          decoration: new BoxDecoration(
                            color: globalDarkTheme().primaryColor,
                            borderRadius:
                                new BorderRadius.all(Radius.circular(20)),
                          ),
                          child: new ListTile(
                              // create new list tile for each task in doc
                              shape: RoundedRectangleBorder(),
                              title: new Text(
                                t.name ?? "Task",
                                style: Theme.of(context).textTheme.headline6,
                              ),
                              leading: getPriorityIcon(t.priority ?? 0),
                              trailing: TaskMenu(
                                task: t,
                              )),
                        ),
                        new Divider(
                          color: Colors.transparent,
                        ),
                      ],
                    ),
                  );
                }).toList();

                // add header to listview
                // tiles.insert(
                //     0,
                //     new ListTile(
                //       onTap: null,
                //       title: Row(children: <Widget>[
                //         Expanded(child: Text("Today's Tasks:")),
                //       ]),
                //     ));
                return new ListView(
                  children: tiles,
                );
            }
          },
        );
      }
    }());
  }
}

class CompletedTasksListView extends StatelessWidget {
  Icon getPriorityIcon(int _priority) {
    List<Icon> _priorityIcons = [
      Icon(
        Icons.lens,
        color: Colors.green,
      ),
      Icon(
        Icons.lens,
        color: Colors.yellow,
      ),
      Icon(
        Icons.lens,
        color: Colors.red,
      ),
    ];
    if (_priority >= 0 && _priority < _priorityIcons.length) {
      return _priorityIcons[_priority];
    } else {
      return _priorityIcons[0]; //default
    }
  }

  @override
  Widget build(BuildContext context) {
    return (() {
      if (_userID == null) {
        return new Text("Sign in first plz");
      } else {
        return new StreamBuilder(
          stream: Firestore.instance
              .collection("users")
              .document(_userID)
              .collection("tasks")
              .where("completed", isEqualTo: true)
              .orderBy("priority", descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
            if (snapshot.data == null) return new Text("No tasks :)");

            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return new Text('Loading...');
              default:
                return new ListView(
                  children: snapshot.data.documents
                      .map<Widget>((DocumentSnapshot value) {
                    // get task obj from each doc in snapshot
                    Task t = Database.buildTaskFromDocSnap(value);

                    return Container(
                      child: Column(
                        children: [
                          Container(
                            decoration: new BoxDecoration(
                              color: globalDarkTheme().primaryColor,
                              borderRadius:
                                  new BorderRadius.all(Radius.circular(20)),
                            ),
                            child: new ListTile(
                                // create new list tile for each task in doc
                                shape: RoundedRectangleBorder(),
                                title: new Text(
                                  t.name ?? "Task",
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                                leading: getPriorityIcon(t.priority ?? 0),
                                trailing: TaskMenu(
                                  task: t,
                                )),
                          ),
                          new Divider(
                            color: Colors.transparent,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
            }
          },
        );
      }
    }());
  }
}

enum TaskMenuOptions { complete, edit }

class TaskMenu extends StatefulWidget {
  final Task task;
  TaskMenu({Key key, this.task}) : super(key: key);

  @override
  _TaskMenuState createState() => _TaskMenuState();
}

class _TaskMenuState extends State<TaskMenu> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<TaskMenuOptions>(
      onSelected: (TaskMenuOptions result) {
        setState(() {
          switch (result) {
            case TaskMenuOptions.complete:
              {
                Database.completeTask(widget.task.name);
              }
              break;
            case TaskMenuOptions.edit:
              {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EditTaskForm(
                              task: widget.task,
                            )));
              }
              break;
          }
        });
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<TaskMenuOptions>>[
        const PopupMenuItem<TaskMenuOptions>(
          value: TaskMenuOptions.complete,
          child: Text('Complete'),
        ),
        const PopupMenuItem<TaskMenuOptions>(
          value: TaskMenuOptions.edit,
          child: Text('Edit'),
        ),
      ],
    );
  }
}

enum PriorityRadio { low, med, high }

class EditTaskForm extends StatefulWidget {
  final Task task;
  EditTaskForm({Key key, @required this.task}) : super(key: key);

  @override
  _EditTaskFormState createState() => _EditTaskFormState();
}

class _EditTaskFormState extends State<EditTaskForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _name = new TextEditingController();

  Task _oldTask;
  DateTime _date = new DateTime.now();
  PriorityRadio _selectedPriority = PriorityRadio.med;

  @override
  void initState() {
    _oldTask = Task.clone(widget.task);
    _selectedPriority = PriorityRadio.values[_oldTask.priority ?? 0];
    _name.text = widget.task.name.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text("Edit Task"),
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
                  ),
                  Container(
                    height: 200,
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.dateAndTime,
                      initialDateTime: widget.task.dueDate.toDate(),
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
                      child: Text("Edit task"),
                      onPressed: () async {
                        _formKey.currentState.save();
                        if (_name.text != widget.task.name)
                          widget.task.name = _name.text;

                        if (Timestamp.fromDate(_date) != widget.task.dueDate)
                          widget.task.dueDate = Timestamp.fromDate(_date);

                        if (widget.task.priority != _selectedPriority.index)
                          widget.task.priority = _selectedPriority.index;

                        Database.setTask(_oldTask, widget.task);
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
