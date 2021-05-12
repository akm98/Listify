import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';


final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
final CollectionReference teamReference = Firestore.instance.collection('Teams');
final CollectionReference userReference = Firestore.instance.collection('Users');
final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

class Team{

  createTeam(){}

  joinTeam(){}

  getTeamTasksId(int teamNumber)async{
    FirebaseUser user = await firebaseAuth.currentUser();
    await new Future.delayed(const Duration(seconds : 1));
    DocumentSnapshot querySnapshot =await Firestore.instance.collection('Users').document(user.email).get();

    return await querySnapshot.data['teams'][teamNumber].split('-')[0];
  }

  getTeamMembers(int teamNumber) async{
    FirebaseUser user =await firebaseAuth.currentUser();
    await new Future.delayed(const Duration(seconds : 1));
    CollectionReference teamReference = Firestore.instance.collection('Teams');
    var teamList = await userReference.document(user.email).get();

    var teamId =await (teamList.data['teams'][teamNumber].split('-')[0]);
    var teamDoc =await teamReference.document(teamId).get();
    var teamUsersEmail = teamDoc.data['users'];
    return teamUsersEmail;
  }

  Future<String> getTeamNameandId(teamNumber)async{
    FirebaseUser user =await firebaseAuth.currentUser();
    await new Future.delayed(const Duration(seconds : 5));
    var teamList = await Firestore.instance.collection('Users').document(user.email).get();

    var teamNameandId =await (teamList.data['teams'][teamNumber]);
    return teamNameandId;
  }

}

//------------------User---------------------//

class User {
  String userName;
  String userEmail;
  var userTeamList;


  Future<List> getDetails() async {
    final FirebaseUser user = await firebaseAuth.currentUser();
    userName = user.displayName ?? 'guest';
    userEmail = user.email ?? 'guest@email.com';
    var profileImgUrl = user.photoUrl ??
        'https://massnutritions.com/assets/images/pi.png';
    var details = [userName, userEmail, profileImgUrl];
    return details;
  }

  getUserTeamList() async {
    FirebaseUser user = await firebaseAuth.currentUser();
    return await userReference.document(user.email).get();
  }

  leaveTeam(teamNumber, context) async {
    FirebaseUser user = await firebaseAuth.currentUser();
    DocumentReference userFields = userReference.document(user.email);
    DocumentSnapshot userDetails = await userFields.get();

    var teamDetails = userDetails.data['teams'][teamNumber];
    var teamId = teamDetails.split('-')[0];
    DocumentReference teamFields = teamReference.document(teamId);


    if (userDetails.data['teams'].length == 1) {
      teamFields.updateData({'users': FieldValue.arrayRemove([user.displayName + ' #%^)(^%# ' + user.email])});
      userFields.updateData({'teams': FieldValue.arrayRemove([teamDetails])});
      firebaseMessaging.unsubscribeFromTopic(teamId);
      
      userFields.updateData({'has_team': false});
      Navigator.of(context).pushNamedAndRemoveUntil(
          '/createjoinpage', (Route<dynamic> route) => false);
    }
    else {
      teamFields.updateData({'users': FieldValue.arrayRemove([user.displayName + ' #%^)(^%# ' + user.email])});
      userFields.updateData({'teams': FieldValue.arrayRemove([teamDetails])});
      firebaseMessaging.unsubscribeFromTopic(teamId);
      return 'done';
    }
  }
}


class FirebaseDataOperations{

  add(String item,int teamNumber)async{
    FirebaseUser user = await firebaseAuth.currentUser();
    var querySnapshot =await Firestore.instance.collection('Users').document(user.email).get();
    String teamId =querySnapshot.data['teams'][teamNumber].split('-')[0] ;
    CollectionReference collectionReference = Firestore.instance.collection('Teams').document(teamId).collection('teamItemList');
    collectionReference.add({'name':item,'createdAt':Timestamp.now(),'createdBy':user.displayName});
  }

  delete(int teamNumber, Timestamp createdAt)async{
    FirebaseUser user = await firebaseAuth.currentUser();
    var qSnapshot =await Firestore.instance.collection('Users').document(user.email).get();
    String teamId =qSnapshot.data['teams'][teamNumber].split('-')[0] ;
    CollectionReference collectionReference = Firestore.instance.collection('Teams').document(teamId).collection('teamItemList');
    QuerySnapshot querySnapshot = await collectionReference.getDocuments();
    var deletethisdoc;
    for(var i in querySnapshot.documents){

      if(i.data['createdAt']==createdAt){
        deletethisdoc = i;
        break;
      }
    }
    deletethisdoc.reference.delete();

  }

}