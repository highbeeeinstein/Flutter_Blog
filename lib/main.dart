import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blog/models/post_model.dart';
import 'package:flutter_blog/screens/home.dart';
import 'package:provider/provider.dart';

final ThemeData _appTheme = _buildAppTheme();

ThemeData _buildAppTheme() {
  ThemeData base = ThemeData.light();
  return base.copyWith(
    primaryColor: Color(0xFF8A0202),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      color: Colors.white,
      iconTheme: IconThemeData(color: Color(0xFF8A0202)),
      foregroundColor: Color(0xFF8A0202),
      elevation: 0,
      brightness: Brightness.light,
    ),
    textTheme: TextTheme(
      headline1: TextStyle(fontSize: 52.0, fontWeight: FontWeight.bold),
      headline2: TextStyle(fontSize: 48.0, fontWeight: FontWeight.bold),
      headline3: TextStyle(fontSize: 36.0, fontWeight: FontWeight.bold),
      headline4: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
      headline5: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
      headline6: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
      bodyText2: TextStyle(fontSize: 14.0),
    ).apply(
        fontFamily: "Poppins", 
        bodyColor: Color(0xFF3E3E3E),
        displayColor: Color(0xFF3E3E3E)),
  );
}

void main() async {
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  runApp(ChangeNotifierProvider(
    create: (context) => PostModel(),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _appTheme,
      home: Home(),
    ),
  ));
}
