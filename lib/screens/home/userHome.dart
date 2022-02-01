import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:lockstars_app/cards/transactTile.dart';
import 'package:lockstars_app/cards/userCard.dart';
import 'package:lockstars_app/cardsLists/lockerList.dart';
import 'package:lockstars_app/cardsLists/messgeList.dart';
import 'package:lockstars_app/models/lockerDoor.dart';
import 'package:lockstars_app/models/message.dart';
import 'package:lockstars_app/models/user.dart';
import 'package:lockstars_app/screens/home/booking.dart';
import 'package:lockstars_app/screens/home/changeLocker.dart';
import 'package:lockstars_app/screens/home/charges.dart';
import 'package:lockstars_app/screens/home/notifs.dart';
import 'package:lockstars_app/screens/home/openLocker.dart';
import 'package:lockstars_app/screens/home/initOpenLocker.dart';
import 'package:lockstars_app/screens/home/registration.dart';
import 'package:lockstars_app/screens/home/reserving.dart';
import 'package:lockstars_app/screens/home/wallet.dart';
import 'package:lockstars_app/screens/home/about.dart';
import 'package:lockstars_app/screens/home/help.dart';
import 'package:lockstars_app/services/auth.dart';
import 'package:lockstars_app/services/database.dart';
import 'package:lockstars_app/services/qrscanning.dart';
import 'package:lockstars_app/shared/globals.dart';
import 'package:provider/provider.dart';
import 'package:lockstars_app/screens/auth/db_provider.dart';
//import 'dart:html' as html;

/*void main() {
  runApp(userHome());
}*/

class userHome extends StatelessWidget {
  userHome({Key? key, required this.uid}) : super(key: key);
  final String uid;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(uid: uid),
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder>{
        '/booking': (BuildContext context) {
          return BookingPage(uid: uid);
        },
        '/openlocker': (BuildContext context) {
          return OpenLockerPage(uid: uid);
        },
        '/initialopen': (BuildContext context) {
          return initOpenLockerPage(uid: uid);
        },
        '/changelocker': (BuildContext context) {
          return ChangeLockerPage(uid: uid);
        },
        '/confirmbooking': (BuildContext context) {
          return ReservingPage(uid: uid);
        },
        '/registration': (BuildContext context) {
          return RegistrationPage(uid: uid);
        },
        '/wallet': (BuildContext context) {
          return WalletPage(uid: uid);
        },
        '/notifs': (BuildContext context) {
          return NotifPage(uid: uid);
        },
        '/charges': (BuildContext context) {
          return ChargesPage(uid: uid);
        },
        '/about': (BuildContext context) {
          return AboutPage(uid: uid);
        },
        '/help': (BuildContext context) {
          return HelpPage(uid: uid);
        },
        // '/about': (BuildContext context) {
        //   return Scaffold(
        //     appBar: AppBar(
        //       title: const Text('About Route'),
        //     ),
        //   );
        // }
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.uid}) : super(key: key);

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

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final AuthService _auth = AuthService();
    final DatabaseService _db = DatabaseService(uid: widget.uid);
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return MultiProvider(
        providers: [
          StreamProvider<List<mnotifications>>.value(
            value: _db.notifs,
            initialData: [],
          ),
          StreamProvider<UserData>.value(
            value: _db.userData,
            initialData: GlobalData.whoami,
          ),
          StreamProvider<List<payDoor>>.value(
            value: _db.lockerTransDataP,
            initialData: [],
          ),
          StreamProvider<List<unlockDoor>>.value(
            value: _db.lockerTransDataU,
            initialData: [],
          ),
          StreamProvider<List<pendingDoor>>.value(
            value: _db.lockerTransDataPend,
            initialData: [],
          ),
          StreamProvider<List<initiatorDoor>>.value(
            value: _db.lockerTransDataInit,
            initialData: [],
          ),
        ],
        child: Scaffold(
          drawer: Drawer(
            //semanticLabel: "Account",
            child: ListView(
              // Important: Remove any padding from the ListView.
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                    /*decoration: BoxDecoration(
                      
                      color: Colors.blue,
                    ),*/
                    child: Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 60,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            '${GlobalData.whoami.name == '' ? GlobalData.whoami.mobile : GlobalData.whoami.name}'),
                        Text(
                            '${GlobalData.whoami.email == '' ? "No registered email" : GlobalData.whoami.email}'),
                        Text('${GlobalData.whoami.mobile}'),
                      ],
                    ),
                  ],
                )),

                //Text('test'),

                ListTile(
                  title: Text("Account Details"),
                  leading: Icon(Icons.app_registration_rounded),
                  onTap: () async {
                    Navigator.pushNamed(context, '/registration');
                  },
                ),
                ListTile(
                  title: Text("Wallet"),
                  leading: Icon(Icons.account_balance_wallet_rounded),
                  onTap: () async {
                    Navigator.pushNamed(context, '/wallet');
                  },
                ),
                ListTile(
                  title: Text("Transaction History"),
                  leading: Icon(Icons.history_rounded),
                  onTap: () async {
                    Navigator.pushNamed(context, '/charges');
                  },
                ),
                ListTile(
                  title: Text("About"),
                  leading: Icon(Icons.info),
                  onTap: () async {
                    Navigator.pushNamed(context, '/about');
                  },
                ),
                ListTile(
                  title: Text("Help"),
                  leading: Icon(Icons.help_center_rounded),
                  onTap: () async {
                    //html.window.open("https://dev.reconlab.co", "Reconlab Dev");
                    Navigator.pushNamed(context, '/help');
                  },
                ),
                ListTile(
                  title: Text("Logout"),
                  leading: Icon(Icons.logout_rounded),
                  onTap: () async {
                    await _auth.signOut();
                  },
                ),
              ],
            ), // Populate the Drawer in the next step.
          ),
          appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Text("Lockstars"),
            elevation: 0.0,
            actions: <Widget>[
              TextButton.icon(
                icon: Icon(_db.newmsg
                    ? Icons.notifications_active_sharp
                    : Icons.notifications),
                label: Text(''),
                style: TextButton.styleFrom(primary: Colors.white),
                onPressed: () async {
                  if (GlobalData.whoami.registered ?? false) {
                    Navigator.pushNamed(context, '/notifs');
                  }
                },
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            //onPressed: () => scanner.scan(),
            onPressed: () {
              print("email is ${GlobalData.whoami.email}");
              if (!(GlobalData.whoami.registered ?? false)) {
                Navigator.pushNamed(context, '/registration');
              } else {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => QRViewF(
                    uid: widget.uid,
                  ),
                ));
              }
              /*Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BookingPage(uid: widget.uid)));*/
              /*
        cameraScanResult = null;
        cameraScanResult = await scanner.scan();
        if (cameraScanResult != null) {
          processQR(cameraScanResult);
          showAlert(context);
        }*/
              //_showBookingsPanel();
            }, // () => _showBookingsPanel(),
            tooltip: 'New Booking',
            label: Text('Book New'),
            icon: Icon(Icons.qr_code_rounded),
            //child: const Icon(Icons.qr_code_scanner),
            backgroundColor: Colors.blue,
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          body: Container(
            child: new SingleChildScrollView(
              child: new Column(
                children: [
                  //USERCARD(),
                  //nList(),
                  iList(),
                  pendList(),
                  pList(),
                  uList(),
                ],
              ),
            ),
          ),
          bottomSheet: Card(
            child: USERCARD(),
          ),
        ));
  }
}
