import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:lockstars_app/cards/userCard.dart';
import 'package:lockstars_app/models/lockerDoor.dart';
import 'package:lockstars_app/models/user.dart';
import 'package:lockstars_app/services/auth.dart';
import 'package:lockstars_app/services/database.dart';
import 'package:lockstars_app/shared/globals.dart';
import 'package:provider/provider.dart';

class ReservingPage extends StatefulWidget {
  ReservingPage({Key? key, required this.uid}) : super(key: key);
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

class _MyHomePageState extends State<ReservingPage> {
  final _formKey = GlobalKey<FormState>();
  var _payer = "";
  var _unlocker = "";

  final TextEditingController pcontroller = TextEditingController();
  final TextEditingController ucontroller = TextEditingController();
  String initialCountry = 'PH';
  PhoneNumber pnumber = PhoneNumber(isoCode: 'PH');
  PhoneNumber unumber = PhoneNumber(isoCode: 'PH');
  bool payernumberReady = false, unlockernumberReady = false;
  bool isChecked = false;

  var _risChecked = true;

  Timestamp _timenow = Timestamp.now();
  int _payHours = 0;
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _timenow = Timestamp.now();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
      final Timestamp now = Timestamp.now();
      setState(() {
        _timenow = now;
        _payHours = ((now.millisecondsSinceEpoch -
                    (transactionData.selStartTime.millisecondsSinceEpoch +
                        3600000)) /
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
    bool checkingLocker = true;
    return MultiProvider(
        providers: [
          StreamProvider<UserData>.value(
            value: _db.userData,
            initialData: GlobalData.whoami,
          ),
        ],
        child: Scaffold(
          appBar: AppBar(
            title: Text("Booking Confirmation"),
            elevation: 0.0,
            actions: <Widget>[
              TextButton.icon(
                icon: Icon(Icons.cancel_rounded),
                label: Text(''),
                style: TextButton.styleFrom(primary: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            //onPressed: () => scanner.scan(),
            onPressed: (_timenow.millisecondsSinceEpoch -
                            transactionData
                                .selStartTime.millisecondsSinceEpoch) /
                        1000 >
                    900 //more than 15 minutes already
                ? null
                : () async {
                    double balance = (GlobalData.whoami.paywallet ?? 0) +
                        (GlobalData.whoami.promowallet ?? 0.0);
                    print(
                        "${GlobalData.whoami.mobile} has $balance total stars balance.");
                    if (balance < transactionData.selRate) {
                      //not enough balance to reserve
                      await showInsufficientBalanceAlert(context);
                    } else {
                      print("reserving...");
                      _db.updateTransactField(
                          transactionData.selLocker,
                          "command",
                          "RESERVE,${GlobalData.whoami.mobile},${transactionData.selUnlocker}");
                      Navigator.of(context).pop();
                    }
                  },
            tooltip: 'Confirm Booking',
            label: Text('Confirm Booking'),
            icon: Icon(Icons.book_online_rounded),
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
                      'Confirm Reservations for Locker ${transactionData.selLocker}',
                      style: TextStyle(fontSize: 20.0),
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      'Booking Details',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      'This booking was initiated by ${transactionData.selInitiator} and will expire in ${(15 - ((_timenow.millisecondsSinceEpoch - transactionData.selStartTime.millisecondsSinceEpoch) / 60000)).toStringAsFixed(0)} minutes.',
                      style: TextStyle(fontSize: 12.0),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'The initiator had set ${transactionData.selUnlocker} as the unlocker. You may change this later.',
                      style: TextStyle(fontSize: 12.0),
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      'Terms and Rate',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      'You shall be charged ${transactionData.selRate} stars for the 1st hour, upon confirmation and ${transactionData.selRate} stars/hr (or fraction thereof) thereafter until ${transactionData.selUnlocker} opens the locker.',
                      style: TextStyle(fontSize: 12.0),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'A grace period of 15 minutes shall be provided before the next hour after confirmation.',
                      style: TextStyle(fontSize: 12.0),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'As payer, you can change whom you set as unlocker after confirmation.',
                      style: TextStyle(fontSize: 12.0),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      'End of Terms',
                      style: TextStyle(fontSize: 12.0),
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      'Only confirm bookings you have knowledge about.',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Tap the button below to cancel unknown bookings.',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    SizedBox(height: 20.0),
                    TextButton(
                      onPressed: () async {
                        var popnow = await cancelBooking(context);
                        if (popnow) {
                          print("canceling booking");
                          _db.updateTransactField(transactionData.selLocker,
                              "command", "CANCEL,${GlobalData.whoami.mobile}");
                          Navigator.pop(context);
                        }
                      },
                      child: new Text("Cancel this booking"),
                    ),
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

  Future<bool> cancelBooking(BuildContext context) async {
    bool ret = false;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Cancel this Booking"),
          actions: <Widget>[
            Column(
              children: [
                Text(
                    "Press Yes to cancel the booking for ${transactionData.selLocker}."),
                Row(
                  children: [
                    TextButton(
                      child: new Text("Yes"),
                      onPressed: () {
                        ret = true;
                        //Navigator.popUntil(context, ModalRoute.withName('/'));
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: new Text("No"),
                      onPressed: () {
                        ret = false;
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                )
              ],
            ),
          ],
        );
      },
    );
    return ret;
  }

  Future<void> showInsufficientBalanceAlert(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Not Enough Stars"),
          actions: <Widget>[
            Column(
              children: [
                Text(
                    "It seems you do not have enough stars in your wallet to confirm this booking."),
                Text(
                    "There are multiple convenient ways to load your wallet. Please head to your wallet page to purchase stars."),
                Row(
                  children: [
                    TextButton(
                      child: new Text("OK"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                )
              ],
            ),
          ],
        );
      },
    );
  }
}
