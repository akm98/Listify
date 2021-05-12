import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lister/loginmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  LoginManager loginManager = new LoginManager();
  bool status=false;



  //---------------UI components-------------------------//

  final Color primaryColor = Color(0xff18203d);
  final Color secondaryColor = Color(0xff232c51);
  final Color logoGreen = Color(0xff25bcbb);

  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body:
      Container(
        margin: EdgeInsets.symmetric(horizontal: 40),
        child: Column(children: <Widget>[
          Text(
            'Sign in to Listify and continue',
            textAlign: TextAlign.center,
            style:
            GoogleFonts.openSans(color: Colors.white, fontSize: 28),
          ),
          SizedBox(height: 20),
          Text(
            'Enter your email and password below to continue.\n Let your productivity begins!',
            textAlign: TextAlign.center,
            style:
            GoogleFonts.openSans(color: Colors.white, fontSize: 14),
          ),
          SizedBox(
            height: 50,
          ),
          _buildTextField('Email',Icons.account_circle),
          SizedBox(height: 20),
          _buildTextField('password',Icons.lock),
          SizedBox(height: 40),
          MaterialButton(
            elevation: 0,
            minWidth: double.maxFinite,
            height: 50,
            onPressed: _fLogin,
            color: logoGreen,
            child: Text('Login',
                style: TextStyle(color: Colors.white, fontSize: 16)),
            textColor: Colors.white,
          ),
          SizedBox(height: 20),
          MaterialButton(
            elevation: 0,
            minWidth: double.maxFinite,
            height: 50,
            onPressed: _gSignIn,
            color: Colors.blue,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FaIcon(FontAwesomeIcons.google),
                SizedBox(width: 10),
                Text('Sign-in using Google',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
            textColor: Colors.white,
          ),
        ],),
      )
    );
  }

  _buildTextField(String labelText,IconData icon){
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: secondaryColor,
          border: Border.all(color: Colors.blueAccent)),
      child: TextField(
        decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
            labelText: labelText,
            labelStyle: TextStyle(color: Colors.white),
            icon: Icon(
              icon,
              color: Colors.white,
            ),
            // prefix: Icon(icon),
            border: InputBorder.none
        ),
      ),
    );
  }

//  _signIn() async{
//    FirebaseUser firebaseUser;
//    firebaseAuth.signInWithEmailAndPassword(email: 'akash@test.com', password: '123456').then((authResult){
//      setState(() {
//        Navigator.of(context).pushNamedAndRemoveUntil('/homescreen', (Route<dynamic> route) => false);
//        firebaseUser=authResult.user;
//
//      });
//      print(firebaseUser.email);
//
//    });
//
//  }



//  _gLogout(){
//    print(googleSignIn.currentUser.displayName);
//    googleSignIn.signOut();
//    print('-----signing out------');
//
//  }

  _gSignIn() async{
    String userId = await loginManager.gSignIn();
    if(userId!=null){
      Navigator.of(context).pushNamedAndRemoveUntil('/checkuser', (Route<dynamic> route) => false);
    }
  }

  _fLogin() async{
    String userId = await loginManager.fSignIn();
    if(userId!=null){
      Navigator.of(context).pushNamedAndRemoveUntil('/checkuser', (Route<dynamic> route) => false);
    }
  }
}


