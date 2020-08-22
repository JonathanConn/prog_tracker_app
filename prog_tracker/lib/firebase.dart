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
}

class Database {
  static void addUserToDatabase(FirebaseUser _user) {
    print(_user.uid);
    print(_user.uid.toString());

    // if user not in database add them
    Firestore.instance
        .collection("users")
        .document(_user.uid)
        .get()
        .then((value) {
      if (!value.exists) {
        Firestore.instance.collection("users").document(_user.uid).setData(
            {"name": _user.uid.toString(), "score": 0, "tasks": {}},
            merge: false // merge true overrites data
            );
      }
    });
  }

  static void addTaskToUser(Task _task) {
    Firestore.instance
        .collection("users")
        .document(_user.uid)
        .get()
        .then((value) {
      if (value.exists) {
        Firestore.instance.collection("users").document(_user.uid).setData({
          "tasks": {
            "$_task.name": {
              "name": _task.name,
              "dueDate": _task.dueDate,
              "timeSpent": _task.timeSpent,
              "completed": _task.completed,
              "createdDate": _task.createdDate,
              "startDate": _task.startDate,
              "endDate": _task.endDate,
              "priority": _task.priority
            }
          }
        }, merge: true);
      } else {
        print("USER NOT FOUND");
      }
    });
  }

  static void completeTask(String _taskName) {
    Firestore.instance
        .collection("users")
        .document(_user.uid)
        .get()
        .then((value) {
      if (value.exists) {
      } else {
        print("USER NOT FOUND");
      }
    });
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
                .snapshots(),
            builder: (context, snapshot) {
              DocumentSnapshot doc = snapshot.data;
              if (doc == null) {
                return new Text("No tasks");
              }
              Map<String, dynamic> taskMap = doc.data;
              List<ListTile> tiles = new List<ListTile>();

              taskMap["tasks"].forEach((key, value) {
                tiles.add(
                  ListTile(
                    title: new Text(value["name"] ?? "TaskName"),
                    // ?? is if null then do right side
                    subtitle: new Text(value["description"] ?? ""),
                    leading: getPriorityIcon(value["priority"] ?? 0),
                    // trailing: getCompletedIcon(value["completed"] ?? false),
                    trailing: TaskMenu(
                      taskName: value["name"],
                    ),
                  ),
                );
              });

              return new ListView(
                children: tiles,
              );
            });
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
