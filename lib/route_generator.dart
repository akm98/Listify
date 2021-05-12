import 'package:flutter/material.dart';
import 'package:lister/checkuserstats.dart';
import 'package:lister/createteampage.dart';
import 'package:lister/homepage.dart';
import 'package:lister/jointeampage.dart';
import 'package:lister/loginscreen.dart';
import 'package:lister/main.dart';
import 'package:lister/NewUserHomePage.dart';
import 'onboarding.dart';

class RouteGenerator{
  static Route<dynamic> generateRoute(RouteSettings routeSettings){
    final args = routeSettings.arguments;
    switch(routeSettings.name){
      case '/':
        return MaterialPageRoute(builder: (_)=>SplashScreen());
      case '/loginscreen':
        return MaterialPageRoute(builder: (_)=>LoginScreen());
      case '/homescreen':
        return MaterialPageRoute(builder: (_)=>MyList());
      case '/onboardingscreen':
        return MaterialPageRoute(builder: (_)=>Onboarding());
      case '/createjoinpage':
        return MaterialPageRoute(builder: (_)=>NewUserHomePage());
      case '/createTeam':
        return MaterialPageRoute(builder: (_)=>CreateTeam());
      case '/joinTeam':
        return MaterialPageRoute(builder: (_)=>JoinTeam());
      case '/checkuser':
        return MaterialPageRoute(builder: (_)=>CheckUser());

    }
  }
}