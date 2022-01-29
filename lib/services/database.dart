import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lockstars_app/models/lockerDoor.dart';
import 'package:lockstars_app/models/message.dart';
import 'package:lockstars_app/models/user.dart';
import 'package:lockstars_app/services/gpg.dart';
import 'package:lockstars_app/shared/globals.dart';
import 'package:openpgp/openpgp.dart';
import 'package:provider/provider.dart';

final String domainx = GlobalData.domainx;

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});
  // collection reference
  bool newmsg = false;
  Future<int?> messhash = loadHash();
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  //final CollectionReference lockerCollection =
  //    FirebaseFirestore.instance.collection('lockers');

  final CollectionReference relevantlockerCollection =
      FirebaseFirestore.instance
          .collection('lockers')
          //.doc('pub.lockstarsph.com')
          .doc(domainx)
          .collection('data');

  final CollectionReference messagesCollection = FirebaseFirestore.instance
      .collection('messages'); //.where(u'me',u'==',GlobalData.whoami.mobile);

  final CollectionReference lockerTransactionCollection =
      FirebaseFirestore.instance
          .collection('transactions')
          //.doc('pub.lockstarsph.com')
          .doc(domainx)
          .collection('data');

  Future<void> oldupdateUserData(String pubKey, String pKey, String name,
      String email, String mobile, int wallet) async {
    //return await userCollection.document(uid).setData({
    return await userCollection.doc(uid).set({
      'pubKey': await encodeB64(pubKey),
      'pKey': await encodeB64(pKey),
      'name': name,
      'email': email,
      'mobile': mobile,
      'wallet': wallet,
    });
  }

  Future<bool> accountCheckAndCreation(String uuid, String lmobile) async {
    //DatabaseService _db = DatabaseService(uid: "uuid");
    bool ret = false;
    double newUserStarsOrToken = 0;
    if ((uuid != "") && (lmobile != "")) {
      String dbuid = await mobile2uid(lmobile);
      print("checking if user exists.");
      if (await subsExists(lmobile)) {
        //subscriber has phone number entry
        print("returning user.");
        if (dbuid == uuid) {
          //uid is a match
        } else {
          //authuid and first match dbuid are not same. auth may have created another user
          //this shouldnt happen
        }
        ret = true;
        //public and private keys will be loaded into streaming after login.
      } else {
        print("user does not exists yet. making new entry.");
        //confirm if there are no uids associated with the mobile
        String? emaill = await encodeB64(lmobile);
        KeyPair? kp =
            await generateKeyPair(lmobile, '$emaill@user.locky.app', uuid);
        if (kp != null) {
          newUserStarsOrToken = 400;
          UserData uuser = UserData(
            uid: uuid,
            mobile: lmobile,
            promowallet: 0,
            paywallet: newUserStarsOrToken,
            email: '',
            name: '',
            secret: await encodeB64(uuid),
            pubkey: await encodeB64(kp.publicKey),
            pkey: await encodeB64(kp.privateKey),
          );
          //no entry. probably new, create an entry
          await updateUserData(uuser);
          await createMessage(uuser.mobile, "message", "Welcome Gift",
              "Thank you for signing up. 300 Promo Stars are credited to your account.");
          print("new user. account created.");
          ret = true;
          //transactionData.loading = false;
        }
      }
    }
    return ret;
  }

  dbVal? _userisvalid(DocumentSnapshot snapshot) {
    var ret = dbVal(hasDB: false);
    if (snapshot != null) {
      if (snapshot.exists) {
        ret.hasDB = true;
      } else {
        ret.hasDB = false;
      }
    }
    return ret;
  }

// Stream<UserData> get userData {
  Stream<dbVal?> get validUser {
    return userCollection
        .doc(GlobalData.whoami.uid)
        .snapshots()
        .map(_userisvalid);
  }

  Future<DocumentReference> createMessage(
      String? xme, String xtype, String xtitle, String xmess) async {
    var jdata = {
      "title": xtitle,
      "message": xmess,
      "me": xme,
      "logtime": Timestamp.now(),
      "type": xtype,
    };
    print("creating message=${jdata.toString()}");
    return await messagesCollection.add(jdata);
  }

//UPDATE USER DATA
  Future<void> updateUserData(UserData uuser) async {
    //return await userCollection.document(uid).setData({
    return await userCollection.doc(uuser.uid).set({
      'pubKey': uuser.pubkey, //await encodeB64(uuser.pubkey ?? ""),
      'pKey': uuser.pkey, //await encodeB64(uuser.pkey ?? ""),
      'name': uuser.name,
      'email': uuser.email,
      'mobile': uuser.mobile,
      'wallet': uuser.paywallet,
      'promowallet': uuser.promowallet,
      'lastupdate': DateTime.now(),
      'registered': uuser.registered ?? false,
    });
  }

  Future<String?> checkUserID(String uuid) async {
    return userCollection.doc(uuid).id;
  }

  Future<DocumentSnapshot> getUserDoc(String uuid) async {
    return userCollection.doc(uuid).get();
  }

  Future<UserData?> getUserInfo(String uuid) async {
    UserData? uuser;
    String? userexist = await checkUserID(uuid);
    if (userexist != null) {
      print("user data exists in db.");
      DocumentSnapshot userDoc = await getUserDoc(uuid);
      uuser!.name = userDoc.get("name");
      uuser.email = userDoc.get("email");
      uuser.pkey = userDoc.get("pKey");
      uuser.pubkey = userDoc.get("pubKey");
      uuser.promowallet = userDoc.get("wallet");
      uuser.paywallet = userDoc.get("wallet");
      uuser.uid = uuid;
      uuser.mobile = userDoc.get("mobile");
      uuser.secret = await encodeB64(uuid);
      return uuser;
    } else {
      return null;
    }
  }

  Future getLockerField(String uuid, String fld) async {
    DocumentSnapshot ss;
    if (uuid.contains(domainx)) {
      //with domain info
      ss = await relevantlockerCollection.doc(uuid).get();
    } else {
      ss = await relevantlockerCollection.doc("$uuid@$domainx").get();
    }
    var res = ss.get(fld);
    return res;
  }

  Future getTransactionField(String uuid, String fld) async {
    DocumentSnapshot ss;
    if (uuid.contains(domainx)) {
      ss = await lockerTransactionCollection.doc(uuid).get();
    } else {
      ss = await lockerTransactionCollection.doc("$uuid@$domainx").get();
    }
    var res = ss.get(fld);
    return res;
  }

  Future isLockerAvailable(String uuid) async {
    DocumentSnapshot ss =
        await lockerTransactionCollection.doc("$uuid@$domainx").get();
    var res = ss.get("status");
    return res == "available";
  }

  Future<String> checkLockerID(String uuid) async {
    return relevantlockerCollection.doc(uuid).id;
  }

  Future<bool> subsExists(String lmobile) async {
    var res = await userCollection
        .where('mobile', isEqualTo: lmobile)
        .get()
        .then((value) {
      return value.size;
    });
    return res > 0;
  }

  Future<String> mobile2uid(String lmobile) async {
    var res = "";
    try {
      res = await userCollection
          .where('mobile', isEqualTo: lmobile)
          .get()
          .then((value) {
        return value.docs.first.id;
      });
    } catch (error) {
      print("error ${error.toString()}");
    }
    return res;
  }

  Future<String> checkSubscriber(List<String> lmobile) async {
    String res = "none";
    await userCollection.where('mobile', whereIn: lmobile).get().then((value) {
      int reqnum = lmobile.length;
      print(
          "there are ${value.size} docs with this mobile and $reqnum is required.");
      if (value.size < reqnum) {
        //no records
        print("insufficient records.");
        res = "none";
      } else {
        //all reqnum is registered
        print("sufficient records.");
        res = "ok";
      }
    });
    return res;
  }

  Future<void> updateUserField(String uid, String field, String val) async {
    //return await userCollection.document(uid).setData({
    return await userCollection.doc(uid).update({
      '$field': val,
    });
  }

  Future<double> getWallet(String payermobile) async {
    double ret = 0;
    String luid = await mobile2uid(payermobile);
    DocumentSnapshot doco = await getUserDoc(luid);
    if (doco.exists) {
      ret = ret + doco.get("wallet");
      ret = ret + doco.get("promowallet");
    }
    return ret;
  }

  Future<void> updateTransactField(
      String luid, String field, String val) async {
    //return await userCollection.document(uid).setData({
    if (luid.contains('@')) {
      return await lockerTransactionCollection.doc("$luid").update({
        '$field': val,
      });
    } else {
      return await lockerTransactionCollection.doc("$luid@$domainx").update({
        '$field': val,
      });
    }
  }

  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    UserData ret = UserData(uid: "");
    if (snapshot.exists) {
      ret = new UserData(
        uid: snapshot.reference.id,
        name: snapshot.get('name'),
        pubkey: snapshot.get('pubKey'),
        pkey: snapshot.get('pKey'),
        email: snapshot.get('email'),
        paywallet: double.parse("${snapshot.get('wallet') ?? 0}"),
        promowallet: double.parse("${snapshot.get('promowallet') ?? 0}"),
        mobile: snapshot.get('mobile'),
        registered: snapshot.get('registered') ?? false,
      );
      GlobalData.whoami.paywallet = ret.paywallet;
      GlobalData.whoami.mobile = ret.mobile;
      GlobalData.whoami.name = ret.name;
      GlobalData.whoami.email = ret.email;
      GlobalData.whoami.promowallet = ret.promowallet;
      GlobalData.whoami.pubkey = ret.pubkey;
      GlobalData.whoami.pkey = ret.pkey;
      GlobalData.whoami.uid = ret.uid;
      GlobalData.whoami.registered = ret.registered;
    } else {
      //if account does not exist, create it.
      print("Creating account for ${GlobalData.whoami.uid ?? ""}.");
      var _created =
          accountCheckAndCreation(this.uid, GlobalData.whoami.mobile ?? "");
    }

    return ret;
    //pkey: snapshot.data()['pKey'],
    //mobile: snapshot.data()['mobile']);
  }

  Stream<UserData> get userData {
    print("monitoring user wallet and others.");
    return userCollection.doc(this.uid).snapshots().map(_userDataFromSnapshot);
  }

//unlock list

  List<unlockDoor> _transDataFromSnapshotU(QuerySnapshot snapshot) {
    var ret = snapshot.docs.map((e) {
      return unlockDoor(
          door: doorTransact(
        uid: e.reference.id,
        command: e.get("command"),
        payer: e.get("payer"),
        unlocker: e.get("unlocker"),
        unlockKey: e.get("unlock_code"),
        initiator: e.get("initiator"),
        rate: double.parse("${e.get("rate") ?? 1}"),
        timestarted: e.get("timestamp"),
        //timestarted: e.get("timestamp")
      ));
    }).toList();
    return ret;
  }

  Stream<List<unlockDoor>> get lockerTransDataU {
    String? number = GlobalData.whoami.mobile ?? '09170919';
    print('payer number is $number');
    final Query transLocker = lockerTransactionCollection
        .where("unlocker", isEqualTo: number)
        .where("status", isEqualTo: "reserved");
    return transLocker.snapshots().map(_transDataFromSnapshotU);
  }

//pay list
  List<payDoor> _transDataFromSnapshotP(QuerySnapshot snapshot) {
    var ret = snapshot.docs.map((e) {
      return payDoor(
          door: doorTransact(
        uid: e.reference.id,
        command: e.get("command"),
        payer: e.get("payer"),
        unlocker: e.get("unlocker"),
        unlockKey: e.get("unlock_code"),
        initiator: e.get("initiator"),
        rate: double.parse("${e.get("rate") ?? 1}"),

        timestarted: e.get("timestamp"),
        //timestarted: e.get("timestamp")
      ));
    }).toList();
    return ret;
  }

  Stream<List<payDoor>> get lockerTransDataP {
    String? number = GlobalData.whoami.mobile ?? '09170919';
    print('payer number is $number');
    final Query transLocker = lockerTransactionCollection
        .where("payer", isEqualTo: number)
        .where("status", isEqualTo: "reserved");
    return transLocker.snapshots().map(_transDataFromSnapshotP);
  }

  //pendingDoor
  List<pendingDoor> _transDataFromSnapshotPend(QuerySnapshot snapshot) {
    var ret = snapshot.docs.map((e) {
      return pendingDoor(
          door: doorTransact(
        uid: e.reference.id,
        command: e.get("command"),
        payer: e.get("payer"),
        unlocker: e.get("unlocker"),
        unlockKey: e.get("unlock_code"),
        initiator: e.get("initiator"),
        rate: double.parse("${e.get("rate") ?? 1}"),

        timestarted: e.get("timestamp"),
        //timestarted: e.get("timestamp")
      ));
    }).toList();
    return ret;
  }

  Stream<List<pendingDoor>> get lockerTransDataPend {
    String? number = GlobalData.whoami.mobile ?? '09170919';
    print('pending payer number is $number');
    final Query transLocker = lockerTransactionCollection
        .where("payer", isEqualTo: number)
        .where("status", isEqualTo: "pending");
    return transLocker.snapshots().map(_transDataFromSnapshotPend);
  }

  //pendingDoor
  List<initiatorDoor> _transDataFromSnapshotInit(QuerySnapshot snapshot) {
    var ret = snapshot.docs.map((e) {
      return initiatorDoor(
          door: doorTransact(
        uid: e.reference.id,
        command: e.get("command"),
        payer: e.get("payer"),
        unlocker: e.get("unlocker"),
        unlockKey: e.get("unlock_code"),
        initiator: e.get("initiator"),
        rate: double.parse("${e.get("rate") ?? 1}"),

        timestarted: e.get("timestamp"),
        //timestarted: e.get("timestamp")
      ));
    }).toList();
    return ret;
  }

  Stream<List<initiatorDoor>> get lockerTransDataInit {
    String? number = GlobalData.whoami.mobile ?? '09170919';
    print('initiator payer number is $number');
    final Query transLocker = lockerTransactionCollection
        .where("initiator", isEqualTo: number)
        .where("status", isEqualTo: "reserved");
    return transLocker.snapshots().map(_transDataFromSnapshotInit);
  }

//notifications
  List<mnotifications> _transNotificationMessage(QuerySnapshot snapshot) {
    var ret = snapshot.docs.map((e) {
      return mnotifications(
          data: messagesForMe(
        logtime: e.get('logtime'),
        message: e.get('message'),
        title: e.get('title'),
        towhom: e.get('me'),
        type: e.get('type'),
      ));
    }).toList();
    /*
    // ignore: unrelated_type_equality_checks
    if (messhash == ret.hashCode) {
      //no change
    } else {
      newmsg = true;
    }
    */
    return ret;
  }

  Stream<List<mnotifications>> get notifs {
    String? number = GlobalData.whoami.mobile ?? '09170919';
    final Query transMessage = messagesCollection
        .limit(32)
        .orderBy("logtime", descending: true)
        .where("me", isEqualTo: number);
    /*
        .where("me", isEqualTo: number)
        //.where("type", isEqualTo: "notification")
        .orderBy("logtime", descending: true);
    //.limit(20);
    */
    return transMessage.snapshots().map(_transNotificationMessage);
  }

  //charges
  List<mcharges> _transChargesMessage(QuerySnapshot snapshot) {
    var ret = snapshot.docs.map((e) {
      return mcharges(
          data: messagesForMe(
        logtime: e.get('logtime'),
        message: e.get('message'),
        title: e.get('title'),
        towhom: e.get('me'),
        type: e.get('type'),
      ));
    }).toList();
    return ret;
  }

  Stream<List<mcharges>> get charges {
    String? number = GlobalData.whoami.mobile ?? '09170919';
    final Query transMessage = messagesCollection
        .limit(16)
        .orderBy("logtime", descending: true)
        .where("type", isEqualTo: "charge")
        .where("me", isEqualTo: number);
    return transMessage.snapshots().map(_transChargesMessage);
  }
/*
// locker list from snapshot
  List<LOCKER> _lockerDataListFromSnapshot(QuerySnapshot snapshot) {
    //return snapshot.documents.map((doc) {
    return snapshot.docs.map((doc) {
      //print(doc.data);
      return LOCKER(
        //name: doc.data()['status'] ?? '',
        name: doc.reference.id ?? '',
        status: doc.data()['status'] ?? '',
      );
    }).toList();
  }

  // locker list from snapshot
  List<LOCKER> _lockerListFromSnapshot(QuerySnapshot snapshot) {
    //return snapshot.documents.map((doc) {
    return snapshot.docs.map((doc) {
      //print(doc.data);
      return LOCKER(
        //name: doc.data()['name'] ?? '',
        name: doc.reference.id ?? '',
        pubKey: doc.data()['pubKey'] ?? '',
        email: doc.data()['email'] ?? '',
        unlockKey: doc.data()['unlockKey'] ?? null,
        expireTime: doc.data()['expireTime'] ?? null,
        unlocker: doc.data()['unlocker'] ?? null,
      );
    }).toList();
  }

// locker data from snapshots
  LOCKER _lockerDataFromSnapshot(DocumentSnapshot snapshot) {
    return LOCKER(
      //name: snapshot.reference.id ?? '',
      name: snapshot.data()['status'] ?? '',
      pubKey: snapshot.data()['pubkey'] ?? '',
    );
  }

  List<LOCKER> _lockerTransactionDataFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return LOCKER(
        name: doc.data()['name'] ?? '',
        pubKey: doc.data()['pubKey'] ?? '',
        email: doc.data()['email'] ?? '',
        unlockKey: doc.data()['unlockKey'] ?? null,
        expireTime: doc.data()['expireTime'] ?? null,
      );
    }).toList();
  }

  List<PAYTRANS> _transDataFromSnapshotP(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return PAYTRANS(
        name: doc.reference.id,
        payer: doc.data()["payer"],
        unlocker: doc.data()["unlocker"],
        unlockcode: doc.data()["unlock_code"],
        //expireTime: doc.data()["code_expiration"],
        paidUntil: doc.data()["paidUntil"],
        timeStamp: doc.data()["timestamp"],
      );
    }).toList();
  }

  List<UNLOCKTRANS> _transDataFromSnapshotU(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return UNLOCKTRANS(
        name: doc.reference.id,
        payer: doc.data()["payer"],
        unlocker: doc.data()["unlocker"],
        unlockcode: doc.data()["unlock_code"],
        //expireTime: doc.data()["code_expiration"],
        paidUntil: doc.data()["paidUntil"],
        timeStamp: doc.data()["timestamp"],
      );
    }).toList();
  }

  // user data from snapshots
/*  List<UserData> _userDataColFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return UserData(
          uid: doc.reference.id,
          name: doc.data()['name'],
          pubkey: doc.data()['pubKey'],
          email: doc.data()['email'],
          wallet: doc.data()['wallet'],
          pkey: doc.data()['pKey'],
          mobile: doc.data()['mobile']);
    }).toList();
  }
*/
  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    return UserData(
        uid: snapshot.reference.id,
        name: snapshot.data()['name'],
        pubkey: snapshot.data()['pubKey'],
        email: snapshot.data()['email'],
        wallet: snapshot.data()['wallet'],
        pkey: snapshot.data()['pKey'],
        mobile: snapshot.data()['mobile']);
  }

  // get lockerl stream
  Stream<List<LOCKER>> get lockerl {
    final Query userLocker =
        relevantlockerCollection.where('status', isNotEqualTo: 'aavailable');
    //relevantlockerCollection.where('unlocker', isEqualTo: GlobalData.mobile);
    return userLocker.snapshots().map(_lockerDataListFromSnapshot);
    //return lockerCollection.snapshots().map(_lockerListFromSnapshot);
  }

  // get lockers where user is involved in stream
  Stream<List<LOCKER>> get lockerRelevant {
    final Query userLocker = lockerTransactionCollection.where('unlocker',
        isNotEqualTo: GlobalData.mobile);
//        relevantlockerCollection.where('status', isEqualTo: 'reserved');
    //relevantlockerCollection.where('unlocker', isEqualTo: GlobalData.mobile);
    return userLocker.snapshots().map(_lockerDataListFromSnapshot);
    //return lockerCollection.snapshots().map(_lockerListFromSnapshot);
  }

  // get user doc stream
/*  Stream<List<UserData>> get userDataCol {
    final Query userMonitor =
        userCollection.where('mobile', isEqualTo: GlobalData.mobile).limit(1);
    return userMonitor.snapshots().map(_userDataColFromSnapshot);
    //return userCollection.doc().snapshots().map(_userDataFromSnapshot);
  }
*/
  Stream<UserData> get userData {
    print('request for info on uid: $uid.');
    return userCollection.doc(uid).snapshots().map(_userDataFromSnapshot);
  }

  Stream<List<PAYTRANS>> get lockerTransDataP {
    var number =
        (GlobalData.mobile ?? '09170919') == '' ? null : GlobalData.mobile;
    print('unlocker number is $number');
    final Query transLocker = lockerTransactionCollection
        //.where("unlocker", is)
        .where("payer", isEqualTo: number ?? 'free');
    //.where("unlocker", isNotEqualTo: 'free');
    return transLocker.snapshots().map(_transDataFromSnapshotP);
  }

  Stream<List<UNLOCKTRANS>> get lockerTransDataU {
    var number =
        (GlobalData.mobile ?? '09170919') == '' ? null : GlobalData.mobile;
    print('payer number is $number');
    final Query transLocker = lockerTransactionCollection
        //.where("unlocker", isNotEqualTo: null);
        .where("unlocker", isEqualTo: number ?? 'free');
    return transLocker.snapshots().map(_transDataFromSnapshotU);
  }
  */
}
