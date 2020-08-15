import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          FirebaseUser user = snapshot.data;
          if (user == null) {
            return SignInPage();
          }
          return HomePage();
        } else {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = new TextEditingController();
  final TextEditingController _password = new TextEditingController();

  // access to our google sign in 
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  //access to firebase 
  final FirebaseAuth _auth = FirebaseAuth.instance; 
  
  Future<void> _signInAnonymously() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
    } catch (e) {
      print(e); // TODO: show dialog with error
    }
  }

  Future<void> _signInGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final FirebaseUser user = (await _auth.signInWithCredential(credential)).user;  
  }


  Future<void> _handleSignInEmail(String _email, String _password) async {
      print('login info $_email  $_password');
      AuthResult result = await _auth.signInWithEmailAndPassword(
        email: _email, password: _password
      );
      final FirebaseUser user = result.user;

      assert(user != null);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);

      print('signInEmail succeeded: $user');

      //return user;

    }

  Future<void> _handleSignUp(email, password) async {

      AuthResult result = await _auth.createUserWithEmailAndPassword(
        email: email, password: password
      );
      final FirebaseUser user = result.user;

      assert (user != null);
      assert (await user.getIdToken() != null);

      //return user;
    } 

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text('Sign in')),
      body: Center(
        child: Column(
        
          children: <Widget>[ 
          
            RaisedButton(
              child: Text('Sign in anonymously'),
              onPressed: _signInAnonymously,
            ),
          
            RaisedButton(
              child: Text('Sign in google'),
              onPressed: _signInGoogle,
            ),


            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[

                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: "Email"),
                ),

                TextFormField(
                controller: _password,
                  obscureText: true,
                  decoration: InputDecoration(labelText: "Pass"),
                ),

                RaisedButton(
                  child: Text('Log in email'),
                  onPressed: () async {
                    _formKey.currentState.save(); 
                   _handleSignInEmail(_email.text, _password.text);
                  }
                ),
                RaisedButton(
                  child: Text('Sign up email'),
                  onPressed: () async {
                    _formKey.currentState.save(); 
                   _handleSignUp(_email.text, _password.text);
                  }
                ),

                ],
              ),
            ),


          ]

        )
      )
    );
  }
}

class HomePage extends StatelessWidget {

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print(e); // TODO: show dialog with error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        actions: <Widget>[
          FlatButton(
            child: Text(
              'Logout',
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.white,
              ),
            ),
            onPressed: _signOut,
          ),
        ],
      ),
      
    );
  }
}