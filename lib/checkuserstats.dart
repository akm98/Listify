import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CheckUser extends StatefulWidget {
  @override
  _CheckUserState createState() => _CheckUserState();
}

class _CheckUserState extends State<CheckUser> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
        body:
        Center(
          child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
          Container(
            child:

                FutureBuilder(
                  future: _userStatus(),
                  builder: (context,snapshot){
                    if(!snapshot.hasData){
                      return CircularProgressIndicator();
                   }
                    return  CircularProgressIndicator(backgroundColor: Colors.red,);
                  }

            ),
          ),
      ],
    ),
        )
    );
  }

  _userStatus() async{
      bool hasTeam;
      FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      FirebaseUser user = await firebaseAuth.currentUser();
      print(user.email);
      var querySnapshot = await Firestore.instance.collection('Users').document(user.email).get();
      hasTeam = await querySnapshot.data['has_team'];

          if(!hasTeam) {
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/createjoinpage', (Route<dynamic> route) => false);

            return '/createjoinpage';
          }else if(hasTeam){
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/homescreen', (Route<dynamic> route) => false);
            return '/homescreen';
          }
  }


}
