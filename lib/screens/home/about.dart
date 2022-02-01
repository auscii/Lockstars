import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lockstars_app/models/user.dart';
import 'package:lockstars_app/services/database.dart';
import 'package:lockstars_app/shared/globals.dart';
import 'package:provider/provider.dart';

class AboutPage extends StatefulWidget {
  AboutPage({Key? key, required this.uid}) : super(key: key);
  final String uid;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<AboutPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final DatabaseService _db = DatabaseService(uid: widget.uid);
    return MultiProvider(
        providers: [
          StreamProvider<UserData>.value(
            value: _db.userData,
            initialData: GlobalData.whoami,
          ),
        ],
        child: Scaffold(
          appBar: AppBar(
            title: Text("About"),
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
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsets.zero,
                    physics: const ScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        Column(children: <Widget>[
                          Image.asset(
                            'assets/images/lockstars-icon.png',
                            fit: BoxFit.contain,
                            width: 130,
                            height: 130,
                          )
                        ]),
                        Container(margin: const EdgeInsets.only(top: 40)),
                        Text(
                          'LOCKSTARS',
                          style: TextStyle(fontSize: 25.0, 
                                           fontWeight: FontWeight.bold,
                                           color: Colors.black),
                        ),
                        Text(
                          'v1.0.9',
                          style: TextStyle(fontSize: 15.0, 
                                           fontStyle: FontStyle.italic,
                                           color: Colors.black),
                        ),
                        Container(margin: const EdgeInsets.only(top: 35)),
                        Text(
                          'Lockstars is a smart locker solutions for safekeeping parcels and other deliveries. This mobile app provides a way to interface with our lockers - booking, reserving and unlocking on site or remotely at your own time and convenience.',
                          style: TextStyle(fontSize: 18.0),
                          textAlign: TextAlign.justify,
                          
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}