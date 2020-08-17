import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

class LoginAuth { 

  static final GoogleSignIn _googleSignIn = GoogleSignIn();
  static final FirebaseAuth _auth = FirebaseAuth.instance; 

  static Future<FirebaseUser> getUser() {
    return _auth.currentUser();
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
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final FirebaseUser user = (await _auth.signInWithCredential(credential)).user;  
    return user;
  }

  static Future<FirebaseUser> handleSignInEmail(String _email, String _password) async {
    AuthResult result = await _auth.signInWithEmailAndPassword(
      email: _email.trim(), password: _password.trim()
    );
    final FirebaseUser user = result.user;

    assert(user != null);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

    return user;
  }

  static Future<FirebaseUser> handleSignUp(String _email, String _password) async {
    AuthResult result = await _auth.createUserWithEmailAndPassword(
      email: _email.trim(), password: _password.trim()
    );
    final FirebaseUser user = result.user;

    assert (user != null);
    assert (await user.getIdToken() != null);

    Database.addUserToDatabase(user);
    return user;
  } 
}

class Database {

 static void addUserToDatabase (FirebaseUser _user){
   print(_user.uid);
   print(_user.uid.toString());
   // if user already exist it will update it
   Firestore.instance.collection("users").document(_user.uid).setData(
     {
      "name" : _user.uid.toString(),
      "score" : 0
     }
   );
   Firestore.instance.collection("users").document(_user.uid).collection("tasks").add(
     {  
      "task_name" : "placeholder_task_name",
      "task_due" : "overdue",
      "time_spent" : 0,
      "completed" : false,



     }
   );


 }

}
