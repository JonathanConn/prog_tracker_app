import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'firebase.dart';

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
          return HomeLoginPage();
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
  
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text('Sign in')),
      body: Center(
        child: Column(
        
          children: <Widget>[ 
          
            RaisedButton(
              child: Text('Sign in anonymously'),
              onPressed: 
                LoginAuth.signInAnonymously,
            ),
          
            RaisedButton(
              child: Text('Sign in google'),
              onPressed: LoginAuth.signInGoogle,
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
                   LoginAuth.handleSignInEmail(_email.text, _password.text);
                  }
                ),
                RaisedButton(
                  child: Text('Sign up email'),
                  onPressed: () async {
                    _formKey.currentState.save(); 
                   LoginAuth.handleSignUp(_email.text, _password.text);
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

class HomeLoginPage extends StatelessWidget {

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
            onPressed: LoginAuth.signOut,
          ),
        ],
      ),
      
    );
  }
}