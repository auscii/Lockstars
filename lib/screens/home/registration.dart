import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:lockstars_app/cards/userCard.dart';
import 'package:lockstars_app/models/lockerDoor.dart';
import 'package:lockstars_app/models/user.dart';
import 'package:lockstars_app/services/auth.dart';
import 'package:lockstars_app/services/database.dart';
import 'package:lockstars_app/shared/constants.dart';
import 'package:lockstars_app/shared/globals.dart';
import 'package:provider/provider.dart';

class RegistrationPage extends StatefulWidget {
  RegistrationPage({Key? key, required this.uid}) : super(key: key);
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

class _MyHomePageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  String? _name = GlobalData.whoami.name;
  String? _email = GlobalData.whoami.email;
  String? _email2 = GlobalData.whoami.email;

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
    Future<void> showAlertP(BuildContext context) async {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("${transactionData.selLocker} Unavailable"),
            actions: <Widget>[
              Text(
                  "This locker is currently unavailable. Kindly select another locker."),
              TextButton(
                child: new Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    return MultiProvider(
        providers: [
          StreamProvider<UserData>.value(
            value: _db.userData,
            initialData: GlobalData.whoami,
          ),
        ],
        child: Scaffold(
          appBar: AppBar(
            title: Text("Registration"),
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
          floatingActionButton: FloatingActionButton.extended(
            //onPressed: () => scanner.scan(),
            onPressed: ((_email == '') || (_email != _email2))
                ? null
                : () async {
                    if (_email2 == _email) {
                      UserData regUser = GlobalData.whoami;
                      regUser.email = _email;
                      regUser.name = _name;
                      regUser.registered = true;
                      if (!(regUser.registered ?? false)) {
                        regUser.promowallet = 400;
                      }
                      await _db.updateUserData(regUser);
                      Navigator.pop(context);
                    }
                  },
            tooltip: 'Register',
            label: Text('Register'),
            icon: Icon(Icons.app_registration_rounded),
            //child: const Icon(Icons.qr_code_scanner),
            backgroundColor: Colors.blue,
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          body: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 15.0),
                    Text(
                      'User Registration',
                      style: TextStyle(fontSize: 20.0),
                    ),
                    Text(
                      'for mobile number ${GlobalData.whoami.mobile}.',
                      style: TextStyle(fontSize: 12.0),
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      'Name',
                      style: TextStyle(fontSize: 18.0),
                    ),
                    SizedBox(height: 10.0),
                    TextFormField(
                      initialValue: _name,
                      decoration: textInputDecoration.copyWith(
                          hintText: 'Enter your name'),
                      validator: (val) =>
                          val!.isEmpty ? 'Enter your name' : null,
                      onChanged: (val) {
                        setState(() => _name = val);
                      },
                    ),
                    SizedBox(height: 10.0),
                    SizedBox(height: 20.0),
                    Text(
                      'Email',
                      style: TextStyle(fontSize: 18.0),
                    ),
                    TextFormField(
                      initialValue: _email,
                      decoration: textInputDecoration.copyWith(
                          hintText: 'Email address'),
                      validator: (val) =>
                          val!.isEmpty ? 'Enter an email' : null,
                      onChanged: (val) {
                        setState(() => _email = val);
                      },
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      'Reenter Email',
                      style: TextStyle(fontSize: 18.0),
                    ),
                    TextFormField(
                      initialValue: _email,
                      decoration: textInputDecoration.copyWith(
                          hintText: 'Email address'),
                      validator: (val) =>
                          val!.isEmpty ? 'Enter same email' : null,
                      onChanged: (val) {
                        setState(() => _email2 = val);
                      },
                    ),
                    SizedBox(height: 30.0),
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
