import 'package:cloud_firestore/cloud_firestore.dart';

class keyLocker {
  String uid;
  String pubKey;
  String? status;

  keyLocker({
    required this.uid,
    required this.pubKey,
    required this.status,
  });
}

class doorTransact {
  String? uid;
  String? command;
  String? unlocker;
  String? initiator;
  String? payer;
  String? unlockKey;
  DateTime? expireTime;
  double? rate;
  Timestamp timestarted;

  doorTransact(
      {required this.uid,
      this.command,
      this.unlocker,
      this.initiator,
      this.payer,
      this.unlockKey,
      this.expireTime,
      this.rate,
      required this.timestarted});
}

class pendingDoor {
  doorTransact door;
  pendingDoor({
    required this.door,
  });
}

class payDoor {
  doorTransact door;
  payDoor({
    required this.door,
  });
}

class unlockDoor {
  doorTransact door;
  unlockDoor({
    required this.door,
  });
}

class initiatorDoor {
  doorTransact door;
  initiatorDoor({
    required this.door,
  });
}
