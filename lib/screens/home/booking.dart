import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:lockstars_app/cards/userCard.dart';
import 'package:lockstars_app/models/lockerDoor.dart';
import 'package:lockstars_app/models/user.dart';
import 'package:lockstars_app/services/auth.dart';
import 'package:lockstars_app/services/database.dart';
import 'package:lockstars_app/shared/globals.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class BookingPage extends StatefulWidget {
  BookingPage({Key? key, required this.uid}) : super(key: key);
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

class _MyHomePageState extends State<BookingPage> {
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
            title: Text("Booking"),
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
            onPressed: !payernumberReady
                ? null
                : !_risChecked
                    ? !unlockernumberReady
                        ? null
                        : () async {
                            if (unlockernumberReady) {
                              //may not be same as payer
                              bool payerSub = await _db.subsExists(_payer);
                              bool unlockerSub =
                                  await _db.subsExists(_unlocker);
                              print(
                                  "payer {$payerSub} unlocker {$unlockerSub}");
                              var r = await _db.updateTransactField(
                                  transactionData.selLocker,
                                  "command",
                                  "BOOK,${GlobalData.whoami.mobile},$_payer,$_unlocker");
                              await _db.createMessage(
                                  _payer,
                                  'notification',
                                  'Booking ${transactionData.selLocker}',
                                  '${GlobalData.whoami.mobile} is booking ${transactionData.selLocker} and assigning you as payer. $_unlocker is set as unlocker');
                              Navigator.pop(context);
                            } else {}
                          }
                    : () async {
                        if (unlockernumberReady) {
                          //same as payer
                          bool payerSub = await _db.subsExists(_payer);
                          bool unlockerSub = await _db.subsExists(_unlocker);
                          print("payer {$payerSub} unlocker {$unlockerSub}");
                          //book
                          var r = await _db.updateTransactField(
                              transactionData.selLocker,
                              "command",
                              "BOOK,${GlobalData.whoami.mobile},$_payer,$_unlocker");
                          await _db.createMessage(
                              _payer,
                              'notification',
                              'Booking ${transactionData.selLocker}',
                              '${GlobalData.whoami.mobile} is booking ${transactionData.selLocker} and assigning you as payer. $_unlocker is set as unlocker');
                          Navigator.pop(context);
                        } else {}
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
                padding: EdgeInsets.zero,
                physics: const ScrollPhysics(),
                scrollDirection: Axis.vertical,
                // shrinkWrap: true,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 15.0),
                    Text(
                      'Reserving Locker ${transactionData.selLocker}',
                      style: TextStyle(fontSize: 20.0),
                    ),
                    Text(
                      'Payer will be charged ${transactionData.selRate} stars for the 1st hour, ${transactionData.selRate} stars/hr thereafter.',
                      style: TextStyle(fontSize: 12.0),
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      'Enter Payer Mobile Info',
                      style: TextStyle(fontSize: 18.0),
                    ),
                    SizedBox(height: 10.0),
                    InternationalPhoneNumberInput(
                      countries: ['PH'],
                      //hintText: "Phone Number",
                      errorMessage: "Invalid Phone Number",
                      //autoFocus: true,
                      onSubmit: () {},
                      onInputChanged: (PhoneNumber number) {
                        print("ptest ${number.phoneNumber}");
                        _payer = number.phoneNumber!;
                      },
                      onInputValidated: (bool value) async {
                        print("payernum: $value <- $payernumberReady");
                        if (value != payernumberReady) {
                          if (value) {
                            if (!payernumberReady) {
                              //from false to true
                              //check if subscriber
                              bool payerSub = await _db.subsExists(_payer);
                              if (!payerSub) {
                                print("payer is not a subscriber.");
                                await showPayerAlert(context);
                              } else {
                                payernumberReady = value;
                              }
                            }
                          } else {
                            //from true to false
                            payernumberReady = false;
                          }
                          setState(() {});
                        }
                      },
                      selectorConfig: SelectorConfig(
                        selectorType:
                            PhoneInputSelectorType.DROPDOWN, // BOTTOM_SHEET,
                      ),
                      ignoreBlank: false,
                      isEnabled: true, //!isChecked,
                      autoValidateMode: AutovalidateMode.disabled,
                      selectorTextStyle: TextStyle(color: Colors.black),
                      initialValue: pnumber,
                      textFieldController: pcontroller,
                      formatInput: false,
                      inputDecoration: InputDecoration(
                        hintText: "Enter Payer Number",
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
                    SizedBox(height: 30.0),
                    Text(
                      'Enter Unlocker Mobile Info',
                      style: TextStyle(fontSize: 18.0),
                    ),
                    SizedBox(height: 10.0),
                    InternationalPhoneNumberInput(
                      countries: ['PH'],
                      //hintText: "Phone Number",
                      errorMessage: "Invalid Phone Number",
                      //autoFocus: true,
                      onSubmit: () {},
                      onInputChanged: (PhoneNumber number) {
                        print("utest ${number.phoneNumber}");
                        _unlocker = number.phoneNumber!;
                      },
                      onInputValidated: (bool value) async {
                        print("unlockernum: $value <- $unlockernumberReady");
                        if (value != unlockernumberReady) {
                          if (value) {
                            if (!unlockernumberReady) {
                              //from false to true
                              //check if subscriber
                              bool unlockerSub =
                                  await _db.subsExists(_unlocker);
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
                      isEnabled: payernumberReady & !isChecked,
                      autoValidateMode: AutovalidateMode.disabled,
                      selectorTextStyle: TextStyle(color: Colors.black),
                      initialValue: unumber,
                      textFieldController: ucontroller,
                      formatInput: false,
                      inputDecoration: InputDecoration(
                        hintText: "Enter Unlocker Number",
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
                      title: const Text('Set payer as unlocker.'),
                      value: isChecked,
                      onChanged: (bool? _value) {
                        setState(() {
                          isChecked = (_value!);
                          if (isChecked) {
                            _unlocker = _payer;
                            unumber = pnumber;
                            if (payernumberReady) {
                              unlockernumberReady = true;
                            }
                          }
                        });
                      },
                    ),
                    SizedBox(height: 30.0),
/*                    CheckboxListTile(
                      controlAffinity: ListTileControlAffinity.leading,
                      title: const Text('Cash on Delivery Type.'),
                      value: false,
                      onChanged: (bool? _value) {
                        setState(() {
                          _risChecked = false; // (_value!);
                        });
                      },
                    ),*/
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

  Future<void> showLockerAlert(BuildContext context) async {
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

  Future<void> showPayerAlert(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("$_payer is not registered"),
          actions: <Widget>[
            Column(
              children: [
                Text(
                    "We cannot find $_payer in our database. Do you want to send an invite for them to join us?"),
                Row(
                  children: [
                    TextButton(
                      child: new Text("Yes"),
                      onPressed: () {
                        sendInvite(_payer,
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

  Future<void> showUnlockerAlert(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("$_unlocker is not registered"),
          actions: <Widget>[
            Column(
              children: [
                Text(
                    "We cannot find $_unlocker in our database. Do you want to send an invite for them to join us?"),
                Row(
                  children: [
                    TextButton(
                      child: new Text("Yes"),
                      onPressed: () {
                        sendInvite(_unlocker,
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
