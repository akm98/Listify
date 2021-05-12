import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as PATH;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lister/loginmanager.dart';
import 'package:lister/bloc.dart';


// Every component in Flutter is a widget, even the whole app itself

class MyList extends StatefulWidget {

  @override
  _MyListState createState() => _MyListState();
}

class _MyListState extends State<MyList> {

  FirebaseDataOperations firebaseDataOperations = new FirebaseDataOperations();
  User appUser = new User();
  Team myTeam = new Team();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  List<Map<String,dynamic>> itemList=[];
  String username ='Guest';
  String email,profileImgUrl = '';
  Map<String,dynamic> data ;
  int teamNumber=0;
  //---------------UI components-------------------------//

  final Color primaryColor = Color(0xff18203d);
  final Color secondaryColor = Color(0xff232c51);
  final Color logoGreen = Color(0xff25bcbb);
  final _biggerFont = TextStyle(fontSize: 18.0);



  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _saveDeviceToken();
    //when in app
  }
  _saveDeviceToken() async{
    FirebaseUser user = await _firebaseAuth.currentUser();
    String fcm_token = await _firebaseMessaging.getToken();
    CollectionReference userReference = Firestore.instance.collection('Users');
    await userReference.document(user.email).updateData({'fcm_token':fcm_token});
    await _firebaseMessaging.subscribeToTopic("all");
  }


  Widget _buildRealTimeList(AsyncSnapshot<dynamic> snapshot){
    return new ListView.builder(
      itemCount: snapshot.data.documents.length,
      itemBuilder: (context,index){
        return _buildTodoItem(snapshot.data.documents[index],index,context);
      },
    );
  }
  // Build a single todo item
  Widget _buildTodoItem(DocumentSnapshot documentSnapshot,int index,BuildContext context) {
    //String itemName, int id,int index
    String itemName = documentSnapshot['name'];
    Timestamp timestamp = documentSnapshot['createdAt'];
    String createdBy = documentSnapshot['createdBy'];
    DateTime date = timestamp.toDate();
    String dateString = DateFormat.yMMMd().add_jm().format(date);
    if(timestamp!=null) {
      return new Dismissible(
        background: Container(
          color: Colors.red,
          padding: EdgeInsets.symmetric(horizontal: 20),
          alignment: AlignmentDirectional.centerStart,
          child: Icon(
            Icons.delete_outline,
            color: Colors.white,
          ),
        ),
        secondaryBackground: Container(
          color: Colors.green,
          padding: EdgeInsets.symmetric(horizontal: 20),
          alignment: AlignmentDirectional.centerEnd,
          child: Icon(
            Icons.archive,
            color: Colors.white,
          ),
        ),

        key: new Key(itemName),
        child:
        ExpansionTile(
            leading: new Text((index + 1).toString(), style: _biggerFont,),
            title: new Text(itemName, style: _biggerFont,),
            children: <Widget>[

              Padding(
                padding: const EdgeInsets.only(bottom:15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text('Added by: $createdBy'),
                    Text(dateString),
                  ],
                ),
              ),

            ],

           // onTap: () => _promptRemoveTodoItem(index, itemName, timestamp)
        ),
        onDismissed: (direction) {
          //TODO : implement Archive item
//          if(direction == DismissDirection.startToEnd)
            firebaseDataOperations.delete(teamNumber, timestamp);
            Scaffold.of(context).showSnackBar(
                new SnackBar(content: new Text('$itemName deleted'),
                  duration: Duration(seconds: 1),));
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        backgroundColor: primaryColor,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.info_outline),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],

          title:FutureBuilder(
            future: _getTeamLists(),
            builder:(context,snapshot){
              if(snapshot.hasData){
                print(snapshot.data['teams']);
                 String teamName = (snapshot.data['teams'][teamNumber].split('-')[1]);
                return new Text(
                  teamName,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.openSans(color: Colors.white, fontSize: 20,fontWeight: FontWeight.bold));
              }
              return new Text('Welcome');
            },
          ),
      ),
      body:Center(
        child: FutureBuilder(
            future:myTeam.getTeamTasksId(teamNumber),
            builder: (context,snapshot){
              if(!snapshot.hasData){

                return CircularProgressIndicator();
              }
              var tId=snapshot.data;
              return StreamBuilder(
                stream: Firestore.instance.collection('Teams')
                    .document(tId).collection('teamItemList').orderBy('createdAt').snapshots(),
                builder: (context,snapshot){
                  if(!snapshot.hasData){
                   return CircularProgressIndicator();
                  }
                  return _buildRealTimeList(snapshot);
                },
              );
            }
        ),
      ),
      drawer: Drawer(

          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              FutureBuilder<List>(
                future: appUser.getDetails(),
                builder:(context,snapshot){
                  if(snapshot.hasData){
                    username = snapshot.data[0].toString();
                    email = snapshot.data[1].toString();
                    profileImgUrl =snapshot.data[2].toString();
                    return _buildUserDrawer(username, email, profileImgUrl);
                  }
                  return CircularProgressIndicator();
                },
              ),

              ExpansionTile(

                leading: FaIcon(FontAwesomeIcons.solidHandshake,color: secondaryColor,),
                title: Text("My Teams",style: TextStyle(fontSize: 16),),
                children: <Widget>[
                  FutureBuilder(
                    future: appUser.getDetails(),
                    builder: (context,snapshot){
                      if(!snapshot.hasData){
                        return CircularProgressIndicator(backgroundColor: Colors.red,strokeWidth: 3,);
                      }
                      var uEmail = snapshot.data[1];
                      return StreamBuilder(
                        stream: Firestore.instance.collection('Users').document(uEmail).snapshots(),
                        builder: (context,snapshot){
                          if(!snapshot.hasData){
                            return CircularProgressIndicator();
                          }
                          return _teamListBuilder(snapshot.data);
                        },
                      );
                    },
                  ),
                ],
              ),
              ListTile(
                leading: FaIcon(FontAwesomeIcons.plus ,color: secondaryColor,),
                title: Text('Create Team',style: TextStyle(fontSize: 16),),
                onTap:(){
                  Navigator.pushNamed(context, '/createTeam');
                },
              ),
              ListTile(
                leading: FaIcon(FontAwesomeIcons.peopleArrows ,color: secondaryColor,),
                title: Text('Join Team',style: TextStyle(fontSize: 16),),
                onTap:(){
                  Navigator.pushNamed(context, '/joinTeam');
                },
              ),
              ListTile(
                leading: FaIcon(FontAwesomeIcons.signOutAlt ,color: secondaryColor,),
                title: Text('Logout',style: TextStyle(fontSize: 16),),
                onTap: _Logout,
              ),
            ],
          ),
      ),
      endDrawer: Drawer(
        child:Container(

            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                ListView(
                  shrinkWrap:true,
                  children: <Widget>[
                    FutureBuilder<String>(
                      future: myTeam.getTeamNameandId(teamNumber),
                      builder: (context,snapshot){

                        if(!snapshot.hasData){
                          return Container(
                              padding: EdgeInsets.all(40),
                              child: Text(''));
                        }
                        return _buildEndDrawer(snapshot.data);
                      },
                    ),
                    FutureBuilder(
                      future: myTeam.getTeamMembers(teamNumber),
                      builder: (context,snapshot){
                        if(!snapshot.hasData){
                         return Container(
                             padding: EdgeInsets.all(40),
                             child: Text('Loading Data...',style: GoogleFonts.openSans(fontSize: 16,)));
                        }
                        //
                        return buildMemberList(snapshot.data);
                      },
                    ),

                  ],
                ),
                 Padding(
                   padding: const EdgeInsets.only(bottom:20),
                   child: MaterialButton(

                      child: Text('Leave team',style: GoogleFonts.openSans(color: Colors.white,fontWeight: FontWeight.bold),),
                      color: Colors.red,
                      onPressed:leaveTeam,
                    ),
                 ),

              ],
            ),
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        backgroundColor: logoGreen,
          onPressed: _pushAddTodoScreen,
          tooltip: 'Add task',
          child: new Icon(Icons.add)
      ),
    );
  }
  Widget _buildUserDrawer(String username,String email,String profileImgUrl){
    return UserAccountsDrawerHeader(
      decoration:BoxDecoration(
        color: primaryColor,
      ),
      accountName: Text(username,style: _biggerFont,),
      accountEmail: Text(email),
      currentAccountPicture: profileImgUrl==null?CircleAvatar(
          child:Text("A",style: TextStyle(fontSize: 40.0))
      ):
      CircleAvatar(
        backgroundImage: NetworkImage(profileImgUrl),
      ),
    );
  }

  void _pushAddTodoScreen() {
    // Push this page onto the stack
    Navigator.of(context).push(
      // MaterialPageRoute will automatically animate the screen entry, as well as adding
      // a back button to close it
        new MaterialPageRoute(
            builder: (context) {
              return new Scaffold(
                  appBar: new AppBar(
                    backgroundColor: primaryColor,
                      title: new Text('Add a new task'),
                  ),
                  body: new TextField(
                    autofocus: true,
                    onSubmitted: (val) {
                      firebaseDataOperations.add(val,teamNumber);
                      Navigator.pop(context); // Close the add todo screen
                    },
                    decoration: new InputDecoration(
                        hintText: 'Enter something to do...',
                        contentPadding: const EdgeInsets.all(16.0)
                    ),
                  )
              );
            }
        )
    );
  }
  _Logout() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final FirebaseUser user = await _firebaseAuth.currentUser();
    prefs.setBool('isLoggedIn',false);
    await FirebaseAuth.instance.signOut();

    print('-----the user has been signed out-------');
    Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
  }

  _getTeamLists() async{

    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    FirebaseUser user =await firebaseAuth.currentUser();
    await new Future.delayed(const Duration(seconds : 1));
    return await Firestore.instance.collection('Users').document(user.email).get();
  }
  
  _teamListBuilder(snapshot) {
    var team =snapshot.data['teams'];
    return new ListView.builder(
      padding: EdgeInsets.zero,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount:  team.length,//snapshot.data.length-3
        itemBuilder: (context, index) {
          String teamName = team[index].split('-')[1];

          var teamId =team[index].split('-')[0];
          if(teamName!=null) {
            return _buildTeamItem(teamId,teamName,index);
          }
          else{
            return _buildTeamItem('Null','Please try again later',1);
          }
        },

    );
  }
  _buildTeamItem(teamId,teamName,index) {

     return new ListTile(
          title: Text(teamName,style:GoogleFonts.openSans(fontWeight:FontWeight.w500,),),
          onTap: (){
          Navigator.pop(context);
          setState(() {
            teamNumber= index;
          });

          },
        );
      }



  Future<String> getTeamDetailsName()async{
    var teamList = await _getTeamLists();
    var teamNameandId =await (teamList.data['teams'][teamNumber]);
    return teamNameandId;
  }

  _buildEndDrawer(teamNameandId){
    String teamName = teamNameandId.split('-')[1];
    String teamId = teamNameandId.split('-')[0];

    return Container(
      padding: EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Text('$teamName',style: GoogleFonts.openSans(fontSize: 24,fontWeight:FontWeight.bold),textAlign: TextAlign.center,),
            Text('Team Code : $teamId',style: GoogleFonts.openSans(fontSize: 15,fontWeight:FontWeight.bold),textAlign: TextAlign.center,),

          ],
        )
    );
  }


  Widget buildMemberList(member) {

    return new ListView.builder(
      shrinkWrap: true,
      itemCount: member.length,
      itemBuilder: (context,index){
        return _buildSingleMember(member[index],index);
      },
    );
  }

  Widget _buildSingleMember(member, int index) {
    String name = member.split(' #%^)(^%# ')[0];
    String email = member.split(' #%^)(^%# ')[1];
    return ListTile(
      contentPadding: EdgeInsets.only(left: 20),
      leading: Container(padding: EdgeInsetsDirectional.only(top:10),child: FaIcon(FontAwesomeIcons.user,color: logoGreen,)),
      title: Text(name,style: GoogleFonts.openSans(fontWeight: FontWeight.bold) ),
      subtitle: Text(email,style: GoogleFonts.openSans()),
    );
  }

  leaveTeam() async{

   var status = await appUser.leaveTeam(teamNumber,context);
    if(status=='done'){
      setState(() {
        teamNumber--;
        Navigator.pop(context);
      });
    }
  }

}
