import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lockstars_app/models/user.dart';
import 'package:lockstars_app/services/database.dart';
import 'package:lockstars_app/shared/globals.dart';
import 'package:provider/provider.dart';

class HelpPage extends StatefulWidget {
  HelpPage({Key? key, required this.uid}) : super(key: key);
  final String uid;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HelpPage> {
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
            title: Text("Help"),
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
                            'assets/images/lockstars-title.png',
                            fit: BoxFit.contain,
                            width: 250,
                            height: 250,
                          )
                        ]),
                        Container(margin: const EdgeInsets.only(top: 10)),
                        Text(
                          'Please reached us and contact this email -> developer@reconlab.co for more information.',
                          style: TextStyle(fontSize: 18.0, 
                                           color: Colors.black),
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