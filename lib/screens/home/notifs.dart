import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:lockstars_app/cards/userCard.dart';
import 'package:lockstars_app/cardsLists/messgeList.dart';
import 'package:lockstars_app/models/lockerDoor.dart';
import 'package:lockstars_app/models/message.dart';
import 'package:lockstars_app/models/user.dart';
import 'package:lockstars_app/services/auth.dart';
import 'package:lockstars_app/services/database.dart';
import 'package:lockstars_app/shared/constants.dart';
import 'package:lockstars_app/shared/globals.dart';
import 'package:provider/provider.dart';

class NotifPage extends StatefulWidget {
  NotifPage({Key? key, required this.uid}) : super(key: key);
  //static const routeName = '/booking';
  final String uid;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<NotifPage> {
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    //final AuthService _auth = AuthService();
    //final args = ModalRoute.of(context)!.settings.arguments as bookLocker;
    final DatabaseService _db = DatabaseService(uid: widget.uid);
    return MultiProvider(
      providers: [
        StreamProvider<List<mnotifications>>.value(
          value: _db.notifs,
          initialData: [],
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text("Notifications"),
          elevation: 0.0,
          actions: <Widget>[
            TextButton.icon(
              icon: Icon(Icons.cancel_rounded),
              label: Text(''),
              style: TextButton.styleFrom(primary: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        body: Container(
          // height: 600,
          height: MediaQuery.of(context).size.height-80,
          alignment: Alignment.topCenter,
          // padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  nList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );

/*
    return MultiProvider(
        providers: [
          StreamProvider<List<mnotifications>>.value(
            value: _db.notifs,
            initialData: [],
          ),
        ],
        child: Scaffold(
          appBar: AppBar(
            title: Text("Notifications"),
            elevation: 0.0,
            actions: <Widget>[
              TextButton.icon(
                icon: Icon(Icons.cancel_rounded),
                label: Text(''),
                style: TextButton.styleFrom(primary: Colors.white),
                onPressed: () {
                  //await _auth.signOut();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          /*
          floatingActionButton: FloatingActionButton.extended(
            //onPressed: () => scanner.scan(),
            onPressed: () async {
              /*if (_email2 == _email) {
                      UserData regUser = GlobalData.whoami;
                      regUser.email = _email;
                      regUser.name = _name;
                      regUser.registered = true;
                      if (!(regUser.registered ?? false)) {
                        regUser.promowallet = 2400;
                      }
                      await _db.updateUserData(regUser);
                      Navigator.pop(context);
                    }*/
            },
            tooltip: 'Email statements for last 3 months',
            label: Text('Email My Activities'),
            icon: Icon(Icons.email_rounded),
            //child: const Icon(Icons.qr_code_scanner),
            backgroundColor: Colors.blue,
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          */
          body: Container(
            alignment: Alignment.topCenter,
            //padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    nList(),
                  ],
                  //USERCARD(),
                ),
              ),
            ),
          ),
          //bottomSheet: Card(
          //  child: USERCARD(),
          //),
        ));
        */
  }
}