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
            {"name": _user.uid.toString(), "score": 0},
            merge: false // merge true overrites data
            );
        Firestore.instance
            .collection("users")
            .document(_user.uid)
            .collection("tasks")
            .add({
          "task_name": "placeholder_task_name",
          "task_due": "overdue",
          "time_spent": 0,
          "completed": false,
        });
      }
    });
  }
}

class TasksListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('users')
          .document(_userID)
          .collection("tasks")
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return new Text('Loading...');
          default:
            return new ListView(
              children:
                  snapshot.data.documents.map((DocumentSnapshot document) {
                return new ListTile(
                  title: new Text(document['name']),
                  // subtitle: new Text(document['task_due'].toString()),
                );
              }).toList(),
            );
        }
      },
    );
  }
}
