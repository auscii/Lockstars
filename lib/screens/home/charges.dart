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

class ChargesPage extends StatefulWidget {
  ChargesPage({Key? key, required this.uid}) : super(key: key);
  //static const routeName = '/booking';
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String uid;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<ChargesPage> {
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    //final AuthService _auth = AuthService();
    final DatabaseService _db = DatabaseService(uid: widget.uid);
    //final args = ModalRoute.of(context)!.settings.arguments as bookLocker;
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return MultiProvider(
        providers: [
          StreamProvider<List<mcharges>>.value(
            value: _db.charges,
            initialData: [],
          ),
        ],
        child: Scaffold(
          appBar: AppBar(
            title: Text("Transactions"),
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
                    cList(),
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
  }
}
