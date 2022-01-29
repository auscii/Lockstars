import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lockstars_app/models/lockerDoor.dart';
import 'package:lockstars_app/models/message.dart';
import 'package:lockstars_app/services/database.dart';
import 'package:lockstars_app/services/gpg.dart';
import 'package:lockstars_app/shared/globals.dart';

class notifmessages extends StatelessWidget {
  final mnotifications mess;
  notifmessages({required this.mess});
  //DatabaseService _db = DatabaseService(uid: GlobalData.uuid);

  late messagesForMe fordisp;
  Future<void> showMsg(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("${fordisp.title}"),
          actions: <Widget>[
            Text(
                "${fordisp.message}\n\n${DateTime.parse(mess.data.logtime!.toDate().toString())}"),
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          leading: Icon(
            mess.data.type == 'notification'
                ? Icons.message_rounded
                : Icons.payment_rounded, // .assistant_photo,
            color: mess.data.type == 'notification'
                ? Colors.green
                : Colors.red, //flagPayment(lockR), //
            //4backgroundColor: _colorStat(lockR.status),
            //backgroundImage: _iconStat(lockR.status),
            //backgroundImage: AssetImage('assets/coffee_icon.png'),
          ),
          /*trailing: CircleAvatar(
            radius: 25.0,
          ),*/
          title:
              Text("${DateTime.parse(mess.data.logtime!.toDate().toString())}"),
          subtitle: Text("${mess.data.title}"),
          onTap: () async {
            fordisp = mess.data;
            await showMsg(context);
          },
        ),
      ),
    );
  }
}

class chargesmessages extends StatelessWidget {
  final mcharges mess;
  chargesmessages({required this.mess});
  //DatabaseService _db = DatabaseService(uid: GlobalData.uuid);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          leading: Icon(
            Icons.payment_rounded, // .assistant_photo,
            color: Colors.red, //flagPayment(lockR), //
            //4backgroundColor: _colorStat(lockR.status),
            //backgroundImage: _iconStat(lockR.status),
            //backgroundImage: AssetImage('assets/coffee_icon.png'),
          ),
          /*trailing: CircleAvatar(
            radius: 25.0,
          ),*/
          title:
              Text("${DateTime.parse(mess.data.logtime!.toDate().toString())}"),
          subtitle: Text("${mess.data.title}"),
          onTap: () {
            /*
            transactionData.selLocker =
                mess.door.uid!.substring(0, mess.door.uid!.indexOf('@'));
            transactionData.selInitiator = mess.door.initiator!;
            transactionData.selPayer = mess.door.payer!;
            transactionData.selUnlocker = mess.door.unlocker!;
            transactionData.selUnlockCode = mess.door.unlockKey!;
            transactionData.selStartTime = mess.door.timestarted;
            transactionData.selRate = mess.door.rate ?? 10;
            print("Tapped ${mess.door.uid} config");
            Navigator.pushNamed(context, '/changelocker');
            //_db.updateTransactField(toPayDoor.name, "command",
            //    "RESERVE,${GlobalData.mobile},${GlobalData.mobile}");
            */
          },
        ),
      ),
    );
  }
}
