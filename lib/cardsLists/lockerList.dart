import 'package:flutter/material.dart';
import 'package:lockstars_app/cards/transactTile.dart';
import 'package:lockstars_app/models/lockerDoor.dart';
import 'package:provider/provider.dart';

class uList extends StatefulWidget {
  @override
  _TransactListUState createState() => _TransactListUState();
}

class _TransactListUState extends State<uList> {
  @override
  Widget build(BuildContext context) {
    //final locksU = Provider.of<List<doorTransact>>(context);
    final locksU = Provider.of<List<unlockDoor>>(context);
    return ListView.builder(
      padding: EdgeInsets.zero,
      physics: const ScrollPhysics(),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: locksU.length,
      itemBuilder: (context, index) {
        return toUnlockLocker(toUnlockDoor: locksU[index]);
      },
    );
  }
}

class pList extends StatefulWidget {
  @override
  _TransactListPState createState() => _TransactListPState();
}

class _TransactListPState extends State<pList> {
  @override
  Widget build(BuildContext context) {
    //final locksU = Provider.of<List<doorTransact>>(context);
    final locksU = Provider.of<List<payDoor>>(context);
    return ListView.builder(
      padding: EdgeInsets.zero,
      physics: const ScrollPhysics(),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: locksU.length,
      itemBuilder: (context, index) {
        return toPayLocker(
          toPayDoor: locksU[index],
        );
      },
    );
  }
}

class pendList extends StatefulWidget {
  @override
  _TransactListPendState createState() => _TransactListPendState();
}

class _TransactListPendState extends State<pendList> {
  @override
  Widget build(BuildContext context) {
    //final locksU = Provider.of<List<doorTransact>>(context);
    final locksU = Provider.of<List<pendingDoor>>(context);
    return ListView.builder(
      padding: EdgeInsets.zero,
      physics: const ScrollPhysics(),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: locksU.length,
      itemBuilder: (context, index) {
        return pendingLocker(
          pendDoor: locksU[index],
        );
      },
    );
  }
}

class iList extends StatefulWidget {
  @override
  _TransactListIState createState() => _TransactListIState();
}

class _TransactListIState extends State<iList> {
  @override
  Widget build(BuildContext context) {
    //final locksU = Provider.of<List<doorTransact>>(context);
    final locksI = Provider.of<List<initiatorDoor>>(context);
    return ListView.builder(
      padding: EdgeInsets.zero,
      physics: const ScrollPhysics(),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: locksI.length,
      itemBuilder: (context, index) {
        return initiatorsLocker(initDoor: locksI[index]);
      },
    );
  }
}
