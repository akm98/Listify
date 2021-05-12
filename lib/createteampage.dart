

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:random_string/random_string.dart';
import 'dart:math' show Random;



class CreateTeam extends StatefulWidget {
  @override
  _CreateTeamState createState() => _CreateTeamState();
}

class _CreateTeamState extends State<CreateTeam> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  ////////////////UI Elements///////////////////////
  final Color primaryColor = Color(0xff18203d);
  final Color secondaryColor = Color(0xff232c51);
  final Color logoGreen = Color(0xff25bcbb);
  final _biggerFont = TextStyle(fontSize: 18.0);

  String teamName='';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        backgroundColor: primaryColor,
        title:Text('CreateTeam')),
      body:Container(
          margin: EdgeInsets.symmetric(horizontal: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Give your team a cool name',
                textAlign: TextAlign.center,
                style:
                GoogleFonts.openSans(color: Colors.blueAccent, fontSize: 24),
              ),

              TextField(
                autofocus: true,
                onChanged: (val){

                  teamName =val;
                },
              ),
              SizedBox(height:50),
              MaterialButton(
                child: Text('Create Team',style: GoogleFonts.openSans(color: Colors.white,fontSize: 24.0,fontWeight: FontWeight.w500),),
                height: 50,
                color: logoGreen,
                minWidth: double.maxFinite,
                onPressed: (){
                  if(teamName!=null){
                     _teamIdPage(teamName);

                  }
                },
              ),
            ],
          )
      ) ,
    );
  }

  _teamIdPage(String tName) {

    Navigator.of(context).push(
      
        new MaterialPageRoute(
            builder: (context) {
              return new Scaffold(
                appBar: new AppBar(
                    backgroundColor: primaryColor,
                    title: new Text('Creating Team')
                ),
                body: Container(
                  margin: EdgeInsets.symmetric(horizontal: 40),
                  child: Column(

                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      FutureBuilder(
                          future: _getTeamId(tName),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              String teamId = snapshot.data.toString();
                              return Column(
                                children: <Widget>[
                                  Text('Give this code to your team members so they can join your team \n',

                                      style: GoogleFonts.openSans(fontSize: 20)
                                  ),
                                  Text( 'Team Code : $teamId',
                                      textAlign: TextAlign.center,
                                      style:
                                      GoogleFonts.openSans(color: Colors.blueAccent,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold)
                                  ),
                                ],
                              );

                            }
                            return CircularProgressIndicator();
                          }
                      ),
                      SizedBox(height:10),
                      MaterialButton(

                        child: Text('Finish',style: GoogleFonts.openSans(color: Colors.white,fontSize: 24.0,fontWeight: FontWeight.w500),),
                        height: 50,
                        color: logoGreen,
                        minWidth: double.maxFinite,
                        onPressed: (){
                          Navigator.of(context).pushNamedAndRemoveUntil('/homescreen', (Route<dynamic> route) => false);
                        },
                      ),
                    ],
                  ),
                ),
              );
            }
        )
                  
    );           
}

  _getTeamId(String tName) async{
    if(tName.contains('-')){

    }
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    FirebaseUser firebaseUser = await firebaseAuth.currentUser();
    CollectionReference teamReference = Firestore.instance.collection('Teams');
    CollectionReference userReference = Firestore.instance.collection('Users');
    QuerySnapshot teamSnapshot = await Firestore.instance.collection('Teams').getDocuments();
    var userSnapshot = await Firestore.instance.collection('Users').document(firebaseUser.email).get();

    String teamId=randomAlphaNumeric(5);
    print(teamId);
    bool teamId_isUnique =true;
    int teamCount = userSnapshot.data.length-2;//////update here if you add extrafield in firebase
    print(teamCount);

    do {
      for (var i in teamSnapshot.documents) {
        if (i.documentID == teamId) {
          print(i.documentID);
          teamId_isUnique = false;
          break;
        }
      }

      if (!teamId_isUnique) {
        teamId = randomAlphaNumeric(5).toUpperCase();
      }
    }while(!teamId_isUnique);


      teamReference.document(teamId).setData({'team_name':tName,'users':FieldValue.arrayUnion([ firebaseUser.displayName+ ' #%^)(^%# '+firebaseUser.email])});
      userReference.document(firebaseUser.email).updateData({'has_team':true,'teams': FieldValue.arrayUnion([teamId+'-'+tName])});

      Firestore.instance.collection('Teams').document(teamId)
          .collection('teamItemList').document().setData({'name':'Welcome '+tName,'createdAt':Timestamp.now()});

    await _firebaseMessaging.subscribeToTopic(teamId);

    return teamId;

  }
}
