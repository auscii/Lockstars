// ----// @dart=2.9
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lockstars_app/models/user.dart';
import 'package:lockstars_app/screens/auth/auth_provider.dart';
import 'package:lockstars_app/screens/auth/db_provider.dart';
import 'package:lockstars_app/screens/auth/phoneSignin.dart';
import 'package:lockstars_app/screens/home/userHome.dart';
import 'package:lockstars_app/screens/loading.dart';
import 'package:lockstars_app/services/auth.dart';
import 'package:lockstars_app/services/database.dart';
import 'package:lockstars_app/shared/globals.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return authProvider(
      auth: AuthService(),
      child: MaterialApp(
        title: 'Lockstars',
        theme: ThemeData(
          // fontFamily: "Montserrat",
          brightness: Brightness.light,
          inputDecorationTheme: InputDecorationTheme(
            contentPadding:
                EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: dbPopulate(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class dbPopulate extends StatelessWidget {
  const dbPopulate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DatabaseService _db =
        DatabaseService(uid: "dummy"); //dbProvider.of(context)!.db;
    //DatabaseService _db = DatabaseService(uid: "dummy");
    return StreamBuilder<dbVal?>(
        stream: _db.validUser,
        builder: (context, AsyncSnapshot snapshot) {
          //builder: (context, snapshot) {
          if (snapshot.hasData) {
            //user already in db
            return userHome(uid: GlobalData.whoami.uid ?? "");
          } else {
            //user is not yet in db
            return Loading();
          }
        });
  }
}
