import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
import 'package:path/path.dart' as PATH;
import 'package:sqflite/sqflite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Welcome to Flutter',
        home:new LoginPage()
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoggedin = false;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn= GoogleSignIn(scopes: ['email']);

  _gSignIn() async{
    final GoogleSignInAccount googleUser = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);

    final FirebaseUser user = (await firebaseAuth.signInWithCredential(credential)).user;

    print(user.displayName);

    setState(() {
      _isLoggedin=true;
    });
  }
  _gLogout(){
    print(googleSignIn.currentUser.displayName);
    googleSignIn.signOut();
    print('-----signing out------');

    setState(() {
      _isLoggedin=false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          backgroundColor: Colors.green,
          title: new Text('G-SignIn')

      ),
      body:Center(
        child:_isLoggedin? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.network(googleSignIn.currentUser.photoUrl,
              height: 100,
              width: 100,
            ),
            Text(googleSignIn.currentUser.email,style: TextStyle(fontSize: 24.0,color: Colors.blue,fontWeight: FontWeight.bold),),
            MaterialButton(
              onPressed:_gLogout,
              color: Colors.teal,
              textColor: Colors.white,
              child: Text('Logout'),
            )
          ],
        )
            :MaterialButton(
          onPressed:_gSignIn,
          color: Colors.white,
          textColor: Colors.black,
          child: Text('Login with Google'),
        ),
      ),
    );
  }
}
