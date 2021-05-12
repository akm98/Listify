import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewUserHomePage extends StatefulWidget {
  @override
  _NewUserHomePageState createState() => _NewUserHomePageState();
}

class _NewUserHomePageState extends State<NewUserHomePage> {


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  ////////////////UI Elements///////////////////////
  final Color primaryColor = Color(0xff18203d);
  final Color secondaryColor = Color(0xff232c51);
  final Color logoGreen = Color(0xff25bcbb);
  final _biggerFont = TextStyle(fontSize: 18.0);

///////////////////FIREBASE///////////////////////
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<List> _getUserdetails() async{

    final FirebaseUser user = await _firebaseAuth.currentUser();

    String username = user.displayName??'guest';
    String email = user.email??'guest@email.com';
    String profileImgUrl = user.photoUrl??'https://massnutritions.com/assets/images/pi.png';

    var details = [username,email,profileImgUrl];
    return details;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        backgroundColor: primaryColor,
        title:Text('Welcome'),
      ),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,

          children: <Widget>[
            FutureBuilder<List>(
              future: _getUserdetails(),
              builder:(context,snapshot){
                if(snapshot.hasData){
                 String username = snapshot.data[0].toString();
                 String email = snapshot.data[1].toString();
                 String profileImgUrl =snapshot.data[2].toString();
                  return _buildUserDrawer(username, email, profileImgUrl);
                }
                return CircularProgressIndicator();
              },
            ),
              ListTile(
                title: Text("Teams"),

              ),

            ListTile(
              title: Text('Logout'),
              onTap: _Logout,
            ),
          ],
        ),
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              Image.asset('assets/images/team.png',height: 150,),
              SizedBox(height: 50,),

              MaterialButton(
                child: Text('Create Team',style: GoogleFonts.openSans(color: Colors.white,fontSize: 24.0,fontWeight: FontWeight.w500),),
                height: 50,
                color: logoGreen,
                minWidth: double.maxFinite,
                onPressed: (){
                  Navigator.of(context).pushNamed('/createTeam');
                },

              ),
              SizedBox(height: 20,),
              MaterialButton(
                child: Text('Join Team',style: GoogleFonts.openSans(color: Colors.white,fontSize: 24.0,fontWeight: FontWeight.w500),),
                height: 50,
                color: logoGreen,
                onPressed: (){
                  Navigator.of(context).pushNamed('/joinTeam');
                },
                minWidth: double.maxFinite,
              ),
            ],
          ),
        ),
      ),
    );
  }
  _Logout() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn',false);
    await FirebaseAuth.instance.signOut();

    print('-----the user has been signed out-------');
    Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
  }
}
