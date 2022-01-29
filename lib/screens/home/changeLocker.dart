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
import 'package:url_launcher/url_launcher.dart';

class ChangeLockerPage extends StatefulWidget {
  ChangeLockerPage({Key? key, required this.uid}) : super(key: key);
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

class _MyHomePageState extends State<ChangeLockerPage> {
  final _formKey = GlobalKey<FormState>();

  Timestamp _timenow = Timestamp.now();
  int _payHours = 0;
  int _mins = 0;

  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _timenow = Timestamp.now();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      final Timestamp now = Timestamp.now();
      setState(() {
        _timenow = now;
        var ntime = ((now.millisecondsSinceEpoch -
                (transactionData.selStartTime.millisecondsSinceEpoch + 0)) /
            3600000);
        _payHours = ntime.toInt();
        int _mintem = ((ntime - _payHours) * 60).toInt();
        _mins = _mintem < 0 ? 0 : _mintem;
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

  var _newunlocker = "";

  final TextEditingController ucontroller = TextEditingController();
  String initialCountry = 'PH';
  PhoneNumber unumber =
      PhoneNumber(isoCode: 'PH', phoneNumber: transactionData.selUnlocker);
  bool unlockernumberReady = false;
  bool isChecked = false;
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
              print("unlockernumber is $unlockernumberReady");
              if (unlockernumberReady) {
                //recheck to make sure
                if (isChecked) {
                  //payer is unlocker
                  if (transactionData.selUnlocker != transactionData.selPayer) {
                    print("updating unlocker to ${transactionData.selPayer}");
                    _db.updateTransactField(transactionData.selLocker,
                        "unlocker", transactionData.selPayer);
                  } else {
                    print("no change");
                  }
                } else {
                  print("whois $_newunlocker");
                  if (transactionData.selUnlocker != _newunlocker) {
                    bool unlockerSub = await _db.subsExists(_newunlocker);
                    if (unlockerSub) {
                      //valid, yes.
                      print("updating unlocker to $_newunlocker");
                      _db.updateTransactField(
                          transactionData.selLocker, "unlocker", _newunlocker);
                    } else {
                      //not a valid user
                    }
                  } else {
                    print("no change");
                  }
                }
                Navigator.pop(context);
              }
            },
            tooltip: 'Save',
            label: Text('Save'),
            icon: Icon(Icons.save_alt_rounded),
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
                      'Initiator',
                      style: TextStyle(fontSize: 18.0),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      "${transactionData.selInitiator}",
                      style: TextStyle(fontSize: 16.0),
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      'Unlocker',
                      style: TextStyle(fontSize: 18.0),
                    ),
                    InternationalPhoneNumberInput(
                      countries: ['PH'],
                      //hintText: "Phone Number",
                      errorMessage: "Invalid Phone Number",
                      //autoFocus: true,
                      onSubmit: () {},
                      onInputChanged: (PhoneNumber number) {
                        print("utest ${number.phoneNumber}");
                        _newunlocker = number.phoneNumber!;
                      },
                      onInputValidated: (bool value) async {
                        print("unlockernum: $value <- $unlockernumberReady");
                        if (value != unlockernumberReady) {
                          if (value) {
                            if (!unlockernumberReady) {
                              //from false to true
                              //check if subscriber
                              bool unlockerSub =
                                  await _db.subsExists(_newunlocker);
                              if (!unlockerSub) {
                                print("unlocker is not a subscriber.");
                                await showUnlockerAlert(context);
                              } else {
                                unlockernumberReady = value;
                              }
                            }
                          } else {
                            //from true to false
                            unlockernumberReady = false;
                          }
                          setState(() {});
                        }
                      },
                      selectorConfig: SelectorConfig(
                        selectorType:
                            PhoneInputSelectorType.DROPDOWN, // BOTTOM_SHEET,
                      ),
                      ignoreBlank: false,
                      isEnabled: !isChecked,
                      autoValidateMode: AutovalidateMode.disabled,
                      selectorTextStyle: TextStyle(color: Colors.black),
                      initialValue: unumber,
                      textFieldController: ucontroller,
                      formatInput: false,
                      inputDecoration: InputDecoration(
                        hintText: "Unlocker Number",
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                          signed: true, decimal: true),
                      onSaved: (PhoneNumber number) {
                        print('On Saved: $number');
                      },
                    ),
                    CheckboxListTile(
                      controlAffinity: ListTileControlAffinity.leading,
                      title: const Text('Set myself as unlocker.'),
                      value: isChecked,
                      onChanged: (bool? _value) {
                        setState(() {
                          isChecked = (_value!);
                          if (isChecked) {
                            _newunlocker = transactionData.selPayer;
                            unlockernumberReady = true;
                          }
                        });
                      },
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      "Booking confirmed on\n${transactionData.selStartTime.toDate().toLocal()}.",
                      style: TextStyle(fontSize: 16.0),
                    ),
                    SizedBox(height: 18.0),
                    Text(
                      "Running cost",
                      style: TextStyle(fontSize: 20.0),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      "$_payHours hrs $_mins mins.\nHourly rate: ${transactionData.selRate} stars\nPending Payment: ${transactionData.selRate * _payHours} stars",
                      style: TextStyle(fontSize: 16.0),
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

  void sendInvite(String mobile, String message) async {
    // Android
    var uri = "sms:$mobile?body=${message.replaceAll(' ', '%20')}";
    if (await canLaunch(uri)) {
      await launch(uri);
    } else {
      // iOS
      var uri = "sms:$mobile?body=${message.replaceAll(' ', '%20')}";
      if (await canLaunch(uri)) {
        await launch(uri);
      } else {
        throw 'Could not launch $uri';
      }
    }
  }

  Future<void> showUnlockerAlert(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("$_newunlocker is not registered"),
          actions: <Widget>[
            Column(
              children: [
                Text(
                    "We cannot find $_newunlocker in our database. Do you want to send an invite for them to join us?"),
                Row(
                  children: [
                    TextButton(
                      child: new Text("Yes"),
                      onPressed: () {
                        sendInvite(_newunlocker,
                            "Hi ${GlobalData.whoami.name} is trying to book locker ${transactionData.selLocker} for you. Lockstars is a SMART locker solution for parcel deliveries and more. Join us at https://lockstarsph.com/getmobile.");
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: new Text("No"),
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
