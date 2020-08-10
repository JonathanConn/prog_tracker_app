import 'login_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  // runApp(MyApp());
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login' : (context) => LoginPage()
      },
    )
   );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return MaterialApp(
      title: 'Peerist',
      theme: ThemeData(
        
        primaryTextTheme: GoogleFonts.robotoMonoTextTheme(textTheme).copyWith(
          headline6: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
            color: Colors.white54,
          ),
        ),

        textTheme: GoogleFonts.robotoMonoTextTheme(textTheme).copyWith(
          title: GoogleFonts.abel(
            textStyle: textTheme.title,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          body1: GoogleFonts.robotoMono(
            textStyle: textTheme.body1,
            color: Colors.white,
          ),
        ),
       

        // Define the default brightness and colors.
        brightness: Brightness.dark,
        primaryColor: Colors.grey[1000],
        accentColor: Colors.orange[600],

    
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      home: Scaffold(
        appBar: AppBar(
          title: Text("Login")
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              MaterialButton(
                onPressed: () => null,
                color: Colors.green,
                child: Text("Login with Google"),
              ),
              
              MaterialButton(
                onPressed: () => null,
                color: Colors.red,
                child: Text("Logout"),
              ),

            ],
          
          ),
        ),
      ),

    );
  }
}

