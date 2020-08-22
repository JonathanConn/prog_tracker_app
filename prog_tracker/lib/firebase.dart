import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

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
  String name;
  int timeSpent, priority;
  Timestamp startDate, endDate, createdDate;
  DateTime dueDate;
  bool completed;

  Task(String name, DateTime dueDate, int priority) {
    this.name = name;
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

  Task.clone(
      String name,
      int timeSpent,
      int priority,
      Timestamp startDate,
      Timestamp endDate,
      Timestamp createdDate,
      DateTime dueDate,
      bool completed) {
    this.name = name;
    this.dueDate = dueDate;
    this.priority = priority;
    this.createdDate = createdDate;
    this.startDate = startDate;
    this.endDate = endDate;
    this.completed = completed;
    this.timeSpent = timeSpent;
    this.priority = priority;
  }
}

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
      Firestore.instance.collection("users").document(_user.uid).setData(
          {"name": _user.uid.toString(), "score": 0, "tasks": {}},
          merge: false // merge true overrites data
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
  }

  static void setTask(Task _task) async {
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
      }, merge: true); //will overwrite
    }
  }

  // finds task in db of user and returns task obj
  static Future<Task> getTask(String _taskName) async {
    Task t;
    if (await checkUser(_user)) {
      Firestore.instance
          .collection("users")
          .document(_user.uid)
          .collection("tasks")
          .document("$_taskName")
          .get()
          .then((val) {
        if (val.exists) {
          t = Task.clone(
              val["name"],
              val["timeSpent"],
              val["priority"],
              val["startDate"],
              val["endDate"],
              val["createdDate"],
              val["dueDate"],
              val["completed"]);
        } else {
          print("task not found");
        }
      });
    }
    return t;
  }

  static void completeTask(String _taskName) async {
    if (await checkUser(_user)) {
    } else {
      print("USER NOT FOUND");
    }
  }
}

class TasksListView extends StatelessWidget {
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

  Icon getCompletedIcon(bool _completed) {
    if (_completed) {
      return Icon(Icons.check_box);
    } else {
      return Icon(Icons.check_box_outline_blank);
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
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
            if (snapshot.data == null) return new Text("No tasks :)");

            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return new Text('Loading...');
              default:
                return new ListView(
                  children:
                      snapshot.data.documents.map((DocumentSnapshot value) {
                    return new ListTile(
                        title: new Text(value["name"] ?? "TaskName"),
                        subtitle: new Text(value["description"] ?? ""),
                        leading: getPriorityIcon(value["priority"] ?? 0),
                        trailing: TaskMenu(taskName: value["name"]));
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
  final String taskName;
  TaskMenu({Key key, this.taskName}) : super(key: key);

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
                Database.completeTask(widget.taskName);
              }
              break;
            case TaskMenuOptions.edit:
              {
                print("pressed edit");
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
