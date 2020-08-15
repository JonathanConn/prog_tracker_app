import 'theme.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatelessWidget {

  // access to our google sign in 
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  //access to firebase 
  final FirebaseAuth _auth = FirebaseAuth.instance; 

  // future is result of async fun, either uncomplete or complete (with val or with error)
  Future<FirebaseUser> _handleSignIn() async {
    
    // holds instance of our user
    FirebaseUser user;

    // check wether the user is already signed in 
    bool isSignedIn = await _googleSignIn.isSignedIn();

    if (isSignedIn) {   // if signed in return cur user
      user = await _auth.currentUser(); // wait for firebase to return cur user
    }
    else {  // start sign in process
      // opens google login pop up
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();

      // extract login info we need
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // store credentials so we can pass them to firebase
      final AuthCredential credential = 
        GoogleAuthProvider.getCredential(
          idToken: googleAuth.idToken, 
          accessToken: googleAuth.accessToken
        );

      // attempt a sign in using firebase
      user = (await _auth.signInWithCredential(credential)).user;
    }
    // google user wrapped in FirebaseUser obj
    return user;
  }


  void onGoogleSignIn(BuildContext context) async {
    FirebaseUser user = await _handleSignIn(); // get user
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => 
        WelcomeUser(user, _googleSignIn)  // pass user to next screen in route
      )
    );
  }

  // what our login page will look like 
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return MaterialApp(
      title: 'Peerist',
      theme: ThemeData(
        textTheme: GoogleFonts.robotoTextTheme(textTheme),
        buttonTheme: ButtonThemeData(
          
        ),
        // Define the default brightness and colors.
        brightness: Brightness.dark,
        primaryColor: Colors.grey[1000],
        accentColor: Colors.orange[600],

    
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      home: Scaffold( 
        body: Container(
            padding: EdgeInsets.all(50),
            child: Align(
              alignment: Alignment.center,
              
              child: FlatButton(  // when pressed try google login
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)
                  ),
                  onPressed: () {  
                    onGoogleSignIn(context);
                  },
                  color: Colors.blueAccent,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                        Icon(
                          Icons.account_circle,
                          color: Colors.white
                        ),
                        SizedBox(width: 10),
                        Text('Login with Google'),
                    ],
                  )
                )
              )
            
            )
          )
      ),
   );
  }
}


class WelcomeUser extends StatelessWidget {
  GoogleSignIn _googleSignIn; 
  FirebaseUser _user;


  WelcomeUser(FirebaseUser user, GoogleSignIn signIn) {
    _user = user;
    _googleSignIn = signIn;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        padding: EdgeInsets.all(50),
        child: Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ClipOval(
                child: Image.network(
                  _user.photoUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover
                )
              ),
              SizedBox(height: 20),
              Text('Welcome,', textAlign: TextAlign.center),
              Text(_user.displayName, textAlign: TextAlign.center, 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
              SizedBox(height: 20),
              FlatButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                onPressed: () {
                  _googleSignIn.signOut();
                  Navigator.pop(context, false);
                },
                color: Colors.redAccent,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.exit_to_app, color: Colors.white),
                      SizedBox(width: 10),
                      Text('Log out of Google', style: TextStyle(color: Colors.white))
                    ],
                  )
                )
              )
          
            ],
          )
        )
      );
  }


}




