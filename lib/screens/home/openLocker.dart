import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:lockstars_app/cards/userCard.dart';
import 'package:lockstars_app/models/lockerDoor.dart';
import 'package:lockstars_app/models/user.dart';
import 'package:lockstars_app/services/auth.dart';
import 'package:lockstars_app/services/database.dart';
import 'package:lockstars_app/services/qrscanning_toUnlock.dart';
import 'package:lockstars_app/shared/constants.dart';
import 'package:lockstars_app/shared/globals.dart';
import 'package:provider/provider.dart';

class OpenLockerPage extends StatefulWidget {
  OpenLockerPage({Key? key, required this.uid}) : super(key: key);
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

class _MyHomePageState extends State<OpenLockerPage> {
  final _formKey = GlobalKey<FormState>();

  Timestamp _timenow = Timestamp.now();
  int _payHours = 0;

  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _timenow = Timestamp.now();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      final Timestamp now = Timestamp.now();
      setState(() {
        _timenow = now;
        _payHours = ((now.millisecondsSinceEpoch -
                    (transactionData.selStartTime.millisecondsSinceEpoch + 0)) /
                3600000)
            .toInt();
      });
    });
  }

  @override
  void dispose() {
    //controller?.dispose();
    if (_timer != null) {
      print("cancelling timer");
      _timer!.cancel();
    }
    super.dispose();
  }

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
    Future<bool> showRemoteUnlockAlert(BuildContext context) async {
      bool ret = false;
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("${transactionData.selLocker} will unlock"),
            actions: <Widget>[
              Text(
                  "We strongly advise using the Scan to Unlock option below.\nIf you still wish to proceed with Remote Unlock, make sure you have a representative standing by on site."),
              TextButton(
                child: new Text("Unlock Remotely"),
                onPressed: () {
                  ret = true;
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: new Text("Cancel"),
                onPressed: () {
                  ret = false;
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return ret;
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
            title: Text("${transactionData.selLocker}"),
            elevation: 0.0,
            actions: <Widget>[
              TextButton.icon(
                icon: Icon(Icons.cancel_rounded),
                label: Text(''),
                style: TextButton.styleFrom(primary: Colors.white),
                onPressed: () {
                  //await _auth.signOut();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              double totalBalance = (GlobalData.whoami.paywallet ?? 0) +
                  (GlobalData.whoami.promowallet ?? 0);
              //await _db.getWallet(transactionData.selPayer);
              print("TAP. balance = $totalBalance");
              if (totalBalance < _payHours * transactionData.selRate) {
                //insufficient funds
                print("payer has insufficient funds.");
              } else {
                transactionData.selChargeHour = _payHours;
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => QRViewF(
                    uid: widget.uid,
                  ),
                ));
                //Navigator.of(context).pop();
              }
            },
            tooltip: 'Scan',
            label: Text('Scan to Unlock'),
            icon: Icon(Icons.lock_open_rounded),
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
                      'Locker Information',
                      style: TextStyle(fontSize: 20.0),
                    ),
                    Text(
                      'for locker ${transactionData.selLocker}',
                      style: TextStyle(fontSize: 12.0),
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      'Payer',
                      style: TextStyle(fontSize: 18.0),
                    ),
                    Text(
                      "${transactionData.selPayer}",
                      style: TextStyle(fontSize: 16.0),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      "Booking confirmed on ${transactionData.selStartTime.toDate().toLocal()}.",
                      style: TextStyle(fontSize: 16.0),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      "Payer will be charged ${(_payHours * transactionData.selRate).toStringAsFixed(2)} stars for $_payHours hours rental.",
                      style: TextStyle(fontSize: 16.0),
                    ),
                    SizedBox(height: 20.0),
                    TextButton(
                        onPressed: () async {
                          bool remunlock = await showRemoteUnlockAlert(context);
                          if (remunlock) {
                            //proceed with remote unlock
                            transactionData.selChargeHour = _payHours;
                            print("unlocking remotely...");
                            _db.updateTransactField(
                                transactionData.selLocker,
                                "command",
                                "OPEN,${transactionData.seldecUnlockCode},$_payHours");
                            Navigator.of(context).pop();
                          } else {
                            //do nothing
                            //Navigator.of(context).pop();
                          }
                        },
                        child: Text("Remote Unlock")),
                    SizedBox(height: 50.0),
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
