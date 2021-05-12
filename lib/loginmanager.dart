import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginManager{

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  final GoogleSignIn googleSignIn= GoogleSignIn(scopes: ['email']);

  gSignIn() async{

    SharedPreferences prefs = await SharedPreferences.getInstance();
    googleSignIn.signOut();

    final GoogleSignInAccount googleUser = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);

    final FirebaseUser user = (await firebaseAuth.signInWithCredential(credential)).user;

    if(user!=null ) {

      prefs.setBool("isLoggedIn", true);
      CollectionReference collectionReference = Firestore.instance.collection('Users');
      var querySnapshot =await Firestore.instance.collection('Users').document(user.email).get();
      if(querySnapshot.data==null){
        collectionReference.document(user.email).setData({'has_team':false});
      }
      return user.uid;
    }
  }

  fSignIn() async{

    String email='akash@test.com';
    String pass='123456';
    try {
      AuthResult result = await firebaseAuth.signInWithEmailAndPassword(
      email: email, password: pass);
      FirebaseUser firebaseUser = result.user;
      CollectionReference collectionReference = Firestore.instance.collection('Users');
      collectionReference.document(firebaseUser.email).setData;

      return firebaseUser.uid;

    }catch(e){
      return false;
    }


  }

}