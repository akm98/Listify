import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class JoinTeam extends StatefulWidget {
  @override
  _JoinTeamState createState() => _JoinTeamState();
}

class _JoinTeamState extends State<JoinTeam> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  ////////////////UI Elements///////////////////////
  final Color primaryColor = Color(0xff18203d);
  final Color secondaryColor = Color(0xff232c51);
  final Color logoGreen = Color(0xff25bcbb);
  final _biggerFont = TextStyle(fontSize: 18.0);

  String teamID='';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
          centerTitle: true,
          backgroundColor: primaryColor,
          title:Text('Join Team')),
      body:Container(
          margin: EdgeInsets.symmetric(horizontal: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Enter your team id',
                textAlign: TextAlign.center,
                style:
                GoogleFonts.openSans(color: Colors.blueAccent, fontSize: 24),
              ),
              TextField(
                autofocus: true,
                onChanged: (val){
                teamID=val.trim();
                },
              ),
              SizedBox(height:50),
              MaterialButton(
                child: Text('Join',style: GoogleFonts.openSans(color: Colors.white,fontSize: 24.0,fontWeight: FontWeight.w500),),
                height: 50,
                color: logoGreen,
                minWidth: double.maxFinite,
                onPressed: (){
                  var teamExists= _authenticateTeam(teamID);
                    if(teamExists!=null){

                      Navigator.of(context).pushNamedAndRemoveUntil('/homescreen', (Route<dynamic> route) => false);
                    }
                    else{
                      SnackBar(content: new Text('Team not found please try again'),duration: Duration(seconds: 2));
                    }
                },
              ),
            ],
          )
      ) ,
    );
  }

  _authenticateTeam(String teamID) async{
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    CollectionReference userReference = Firestore.instance.collection('Users');
    CollectionReference teamReference = Firestore.instance.collection('Teams');
    FirebaseUser user = await firebaseAuth.currentUser();
    bool teamExists =false;

    var teamSnapshot =await teamReference.document(teamID).get();
    if(teamSnapshot.documentID!=null){
      teamExists =true;
      print('============exists=='+teamID);
    }

    if(teamExists) {
      DocumentSnapshot udata =await userReference.document(user.email).get();
      DocumentSnapshot tdata = await teamReference.document(teamID).get();

      var tname =[teamID+'-'+tdata.data['team_name']];
      userReference.document(user.email).updateData({'has_team': true, 'teams':FieldValue.arrayUnion(tname)});//+ucount.toString(): teamID+'-'+tname

      teamReference.document(teamID).updateData({'users': FieldValue.arrayUnion([user.displayName+' #%^)(^%# '+ user.email])});
      await _firebaseMessaging.subscribeToTopic(teamID);


        return 'exits';
    }

    return null;
  }
}
