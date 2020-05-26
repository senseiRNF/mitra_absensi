import 'package:mitraabsensi/screens/absence_screen.dart';
import 'package:mitraabsensi/screens/login_screen.dart';
import 'package:mitraabsensi/screens/home_screen.dart';
import 'package:mitraabsensi/screens/profile_screen.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xffff4105),
      ),
      routes: {
        '/': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/absence': (context) => AbsenceScreen(),
        '/profile': (context) => ProfileScreen(),
      },
    );
  }
}