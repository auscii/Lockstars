import 'dart:convert' as convert;
import 'dart:math';
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
import 'package:lockstars_app/shared/constants.dart';
import 'package:lockstars_app/shared/globals.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';

class WalletPage extends StatefulWidget {
  WalletPage({Key? key, required this.uid}) : super(key: key);
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

class _MyHomePageState extends State<WalletPage> {
  final _formKey = GlobalKey<FormState>();
  int loadAmount = 0;
  String referenceCode = "";
  bool dontallowpay = false;

  String getRandom(int length) {
    const ch = '0123456789ABCDEF';
    Random r = Random();
    return String.fromCharCodes(
        Iterable.generate(length, (_) => ch.codeUnitAt(r.nextInt(ch.length))));
  }

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _launchUniversalLinkIos(String url) async {
    if (await canLaunch(url)) {
      final bool nativeAppLaunchSucceeded = await launch(
        url,
        forceSafariVC: false,
        universalLinksOnly: true,
      );
      if (!nativeAppLaunchSucceeded) {
        await launch(
          url,
          forceSafariVC: true,
        );
      }
    }
  }

  Future<void> _launchInWebViewOrVC(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: true,
        forceWebView: true,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _launchInWebViewWithJavaScript(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: true,
        forceWebView: true,
        enableJavaScript: true,
      );
    } else {
      throw 'Could not launch $url';
    }
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
    Future<void>? _launched;
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
            title: Text("Wallet Details"),
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
              Navigator.pop(context);
            },
            tooltip: 'Load Wallet',
            label: Text('Load Wallet'),
            icon: Icon(Icons.app_registration_rounded),
            //child: const Icon(Icons.qr_code_scanner),
            backgroundColor: Colors.blue,
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          */
          body: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 15.0),
                        Text(
                          'Wallet Details',
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
                        Text(
                          "${GlobalData.whoami.name}",
                          style: TextStyle(fontSize: 18.0),
                        ),
                        SizedBox(height: 10.0),
                        //SizedBox(height: 20.0),
                        Text(
                          'Mobile',
                          style: TextStyle(fontSize: 18.0),
                        ),
                        Text(
                          "${GlobalData.whoami.mobile}",
                          style: TextStyle(fontSize: 18.0),
                        ),

                        SizedBox(height: 30.0),
                        Text(
                          'Regular Stars',
                          style: TextStyle(fontSize: 18.0),
                        ),
                        Text(
                          "${GlobalData.whoami.paywallet?.toStringAsFixed(2)}",
                          style: TextStyle(fontSize: 18.0),
                        ),

                        SizedBox(height: 10.0),
                        Text(
                          'Promo Stars',
                          style: TextStyle(fontSize: 18.0),
                        ),
                        Text(
                          "${GlobalData.whoami.promowallet?.toStringAsFixed(2)}",
                          style: TextStyle(fontSize: 18.0),
                        ),
                        SizedBox(height: 20.0),
                        Column(
                          children: [
                            TextButton(
                                onPressed: dontallowpay
                                    ? null
                                    : () async {
                                        dontallowpay = true;
                                        loadAmount = 10000;
                                        referenceCode =
                                            "${Timestamp.now().millisecondsSinceEpoch}A${getRandom(8)}";
                                        String? redirection =
                                            await loadWallet();
                                        if (redirection == null) {
                                          //fail to get payment link
                                          transactionData.payLink = "";
                                        } else {
                                          //we got payment a link
                                          //send it over to the in-app browser
                                          transactionData.payLink = redirection;
                                          _launched = _launchUniversalLinkIos(
                                              redirection);
                                        }
                                        dontallowpay = false;
                                      },
                                child: Text("100 Stars")),
                            TextButton(
                                onPressed: dontallowpay
                                    ? null
                                    : () async {
                                        dontallowpay = true;
                                        loadAmount = 20000;
                                        referenceCode =
                                            "${Timestamp.now().millisecondsSinceEpoch}A${getRandom(8)}";
                                        String? redirection =
                                            await loadWallet();
                                        if (redirection == null) {
                                          //fail to get payment link
                                          transactionData.payLink = "";
                                        } else {
                                          //we got payment a link
                                          //send it over to the in-app browser
                                          transactionData.payLink = redirection;
                                          _launched = _launchUniversalLinkIos(
                                              redirection);
                                        }
                                        dontallowpay = false;
                                      },
                                child: Text("200 Stars")),
                            TextButton(
                                onPressed: dontallowpay
                                    ? null
                                    : () async {
                                        dontallowpay = true;
                                        loadAmount = 50000;
                                        referenceCode =
                                            "${Timestamp.now().millisecondsSinceEpoch}A${getRandom(8)}";
                                        String? redirection =
                                            await loadWallet();
                                        if (redirection == null) {
                                          //fail to get payment link
                                          transactionData.payLink = "";
                                        } else {
                                          //we got payment a link
                                          //send it over to the in-app browser
                                          transactionData.payLink = redirection;
                                          _launched = _launchUniversalLinkIos(
                                              redirection);
                                        }
                                        dontallowpay = false;
                                      },
                                child: Text("500 Stars")),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          //bottomSheet: Card(
          //  child: USERCARD(),
          //),
        ));
  }

  Future<String?> loadWallet() async {
    print("making the post request");
    final url = Uri.http(
        'dev.reconlab.co:8888', '/loadwallet/${GlobalData.whoami.mobile}', {
      'reference': '$referenceCode',
      'amount': '$loadAmount',
      'currency': 'php',
      'email': '${GlobalData.whoami.email}',
      'mobile': '${GlobalData.whoami.mobile}',
      'name': '${GlobalData.whoami.name ?? "unregistered"}',
      'paywallet': '${GlobalData.whoami.paywallet}',
      'description': '${(loadAmount / 100)} Lockstars Stars'
    });
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      var itemCount = jsonResponse['totalItems'];
      print('returned ${jsonResponse['url']}');
      return '${jsonResponse['url']}';
    } else {
      print('Request failed with status: ${response.statusCode}.');
      return null;
    }
  }
}