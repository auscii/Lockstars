import 'package:flutter/material.dart';
import 'package:lockstars_app/cards/messageTile.dart';
import 'package:lockstars_app/cards/transactTile.dart';
import 'package:lockstars_app/models/lockerDoor.dart';
import 'package:lockstars_app/models/message.dart';
import 'package:provider/provider.dart';

class nList extends StatefulWidget {
  @override
  _TransactListNState createState() => _TransactListNState();
}

class _TransactListNState extends State<nList> {
  @override
  Widget build(BuildContext context) {
    //final locksU = Provider.of<List<doorTransact>>(context);
    final messages = Provider.of<List<mnotifications>>(context);
    return ListView.builder(
      padding: EdgeInsets.zero,
      physics: const ScrollPhysics(),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        return notifmessages(
          mess: messages[index],
        );
      },
    );
  }
}

class cList extends StatefulWidget {
  @override
  _TransactListCState createState() => _TransactListCState();
}

class _TransactListCState extends State<cList> {
  @override
  Widget build(BuildContext context) {
    //final locksU = Provider.of<List<doorTransact>>(context);
    final messages = Provider.of<List<mcharges>>(context);
    return ListView.builder(
      padding: EdgeInsets.zero,
      physics: const ScrollPhysics(),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        return chargesmessages(
           mess: messages[index],
        );
      },
    );
  }
}
