import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lockstars_app/models/lockerDoor.dart';
import 'package:lockstars_app/services/database.dart';
import 'package:lockstars_app/services/gpg.dart';
import 'package:lockstars_app/shared/globals.dart';

class toPayLocker extends StatelessWidget {
  final payDoor toPayDoor;
  toPayLocker({required this.toPayDoor});
  //DatabaseService _db = DatabaseService(uid: GlobalData.uuid);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          leading: Icon(
            Icons.change_circle_rounded, // .assistant_photo,
            color: Colors.blue, //flagPayment(lockR), //
            //4backgroundColor: _colorStat(lockR.status),
            //backgroundImage: _iconStat(lockR.status),
            //backgroundImage: AssetImage('assets/coffee_icon.png'),
          ),
          /*trailing: CircleAvatar(
            radius: 25.0,
          ),*/
          title: Text(
              "${toPayDoor.door.uid!.substring(0, toPayDoor.door.uid!.indexOf('@'))} Modifications"),
          subtitle: Text("May be unlocked by ${toPayDoor.door.unlocker}."),
          onTap: () {
            transactionData.selLocker = toPayDoor.door.uid!
                .substring(0, toPayDoor.door.uid!.indexOf('@'));
            transactionData.selInitiator = toPayDoor.door.initiator!;
            transactionData.selPayer = toPayDoor.door.payer!;
            transactionData.selUnlocker = toPayDoor.door.unlocker!;
            transactionData.selUnlockCode = toPayDoor.door.unlockKey!;
            transactionData.selStartTime = toPayDoor.door.timestarted;
            transactionData.selRate = toPayDoor.door.rate ?? 10;
            print("Tapped ${toPayDoor.door.uid} config");
            Navigator.pushNamed(context, '/changelocker');
            //_db.updateTransactField(toPayDoor.name, "command",
            //    "RESERVE,${GlobalData.mobile},${GlobalData.mobile}");
          },
        ),
      ),
    );
  }
}
/*
flagPayment(PAYTRANS doorTransData) {
  Timestamp tts = Timestamp.fromMillisecondsSinceEpoch(
      doorTransData.timeStamp.millisecondsSinceEpoch +
          (60000 * doorTransData.paidUntil));
  if (tts.compareTo(Timestamp.now()) > 0) {
    return Colors.green;
  } else {
    return Colors.red;
  }
}*/

class toUnlockLocker extends StatelessWidget {
  final unlockDoor toUnlockDoor;
  toUnlockLocker({
    required this.toUnlockDoor,
  });
  /*
  _colorStat(String stt) {
    if (stt == 'available') {
      return Colors.green;
    } else if (stt == 'reserved') {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }

  _iconStat(String stt) {
    if (stt == 'available') {
      return AssetImage('assets/unlocked.png');
    } else if (stt == 'reserved') {
      return AssetImage('assets/locked.png');
    } else {
      return AssetImage('assets/coffee_icon.png');
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Visibility(
      //padding: const EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          leading: Icon(
            Icons.lock_clock_rounded, // .assistant_photo,
            color: Colors.green,
          ),
          title: Text(toUnlockDoor.door.uid!
              .substring(0, toUnlockDoor.door.uid!.indexOf('@'))),
          subtitle: Text('Tap to unlock.'),
          onTap: () async {
            print("Tapped ${toUnlockDoor.door.uid} OPEN");
            transactionData.selLocker = toUnlockDoor.door.uid!
                .substring(0, toUnlockDoor.door.uid!.indexOf('@'));
            transactionData.selInitiator = toUnlockDoor.door.initiator!;
            transactionData.selPayer = toUnlockDoor.door.payer!;
            transactionData.selUnlocker = toUnlockDoor.door.unlocker!;
            transactionData.seldecUnlockCode =
                (await decodeB64(toUnlockDoor.door.unlockKey!))!;
            transactionData.selUnlockCode = toUnlockDoor.door.unlockKey!;
            transactionData.selStartTime = toUnlockDoor.door.timestarted;
            transactionData.selRate = toUnlockDoor.door.rate ?? 10;
            print("Tapped ${toUnlockDoor.door.uid} OPEN");
            Navigator.pushNamed(context, '/openlocker');
          },
        ),
      ),
    );
  }
}

class pendingLocker extends StatelessWidget {
  final pendingDoor pendDoor;
  pendingLocker({required this.pendDoor});
  //DatabaseService _db = DatabaseService(uid: GlobalData.whoami.uid ?? "dummy");

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          leading: Icon(
            Icons.pending_rounded, // .assistant_photo,
            color: Colors.red, //flagPayment(lockR), //
            //4backgroundColor: _colorStat(lockR.status),
            //backgroundImage: _iconStat(lockR.status),
            //backgroundImage: AssetImage('assets/coffee_icon.png'),
          ),
          /*trailing: CircleAvatar(
            radius: 25.0,
          ),*/
          title: Text(
              "${pendDoor.door.uid!.substring(0, pendDoor.door.uid!.indexOf('@'))} Booking pending"),
          subtitle:
              Text("Tap to confirm booking by ${pendDoor.door.initiator}."),
          onTap: () async {
            transactionData.selLocker = pendDoor.door.uid!
                .substring(0, pendDoor.door.uid!.indexOf('@'));
            transactionData.selInitiator = pendDoor.door.initiator!;
            transactionData.selUnlocker = pendDoor.door.unlocker!;
            transactionData.selStartTime = pendDoor.door.timestarted;
            transactionData.selRate = pendDoor.door.rate ?? 10;
            print("Tapped ${pendDoor.door.uid} RESERVE");
            Navigator.pushNamed(context, '/confirmbooking');
          },
        ),
      ),
    );
  }
}

class initiatorsLocker extends StatelessWidget {
  final initiatorDoor initDoor;
  initiatorsLocker({required this.initDoor});
  //DatabaseService _db = DatabaseService(uid: GlobalData.whoami.uid ?? "dummy");

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          leading: Icon(
            Icons
                .tab_unselected_rounded, //pending_rounded, // .assistant_photo,
            color: Colors.amberAccent, //flagPayment(lockR), //
            //4backgroundColor: _colorStat(lockR.status),
            //backgroundImage: _iconStat(lockR.status),
            //backgroundImage: AssetImage('assets/coffee_icon.png'),
          ),
          /*trailing: CircleAvatar(
            radius: 25.0,
          ),*/
          title: Text(
              "${initDoor.door.uid!.substring(0, initDoor.door.uid!.indexOf('@'))} Approved Booking"),
          subtitle: Text("Tap to enter parcel."),
          onTap: () async {
            transactionData.selLocker = initDoor.door.uid!
                .substring(0, initDoor.door.uid!.indexOf('@'));
            transactionData.seldecUnlockCode = initDoor.door.initiator!;
            transactionData.selUnlockCode = initDoor.door.initiator!;
            transactionData.selInitiator = initDoor.door.initiator!;
            transactionData.selUnlocker = initDoor.door.unlocker!;
            transactionData.selStartTime = initDoor.door.timestarted;
            transactionData.selRate = initDoor.door.rate ?? 10;
            print("Tapped ${initDoor.door.uid} OPEN INIT");
            Navigator.pushNamed(context, '/initialopen');
          },
        ),
      ),
    );
  }
}

class EMPTYTILE extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Visibility(
      //padding: const EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          title: Text('No Locker'),
          //subtitle: Text('Tap to unlock.'),
        ),
      ),
    );
  }
}


//