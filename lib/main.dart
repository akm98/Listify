import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lister/loginscreen.dart';
import 'package:lister/route_generator.dart';
import 'dart:async';
import 'package:path/path.dart' as PATH;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generateRoute,

    );
  }
}
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final Color primaryColor = Color(0xff18203d);
  final Color secondaryColor = Color(0xff232c51);
  final Color logoGreen = Color(0xff25bcbb);


  void initState() {
    // TODO: implement initState
    super.initState();
    startTimer();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Container(


       child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: <Widget>[
          Center(
              child: Image.asset('assets/images/onboarding.png',height: 150,),

          ),
           SizedBox(height: 20,),
           Text(
             'Listify',
             textAlign: TextAlign.center,
             style:
             GoogleFonts.openSans(color: Colors.blueAccent, fontSize: 24,fontWeight: FontWeight.bold),
           ),
           ],
          ),
      ),
    );
  }

  void startTimer() {
    Timer(Duration(seconds: 2), () async{
     navigateUser(); //It will redirect  after 3 seconds
    });
  }

  void navigateUser() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var status = prefs.getBool('isLoggedIn') ?? false;
    print('--checking in splash screen--'+status.toString());
    if (status) {
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/checkuser', (Route<dynamic> route) => false);
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil('/onboardingscreen', (Route<dynamic> route) => false);
    }
  }
}


