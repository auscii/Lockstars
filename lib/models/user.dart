//import 'dart:ffi';

class UserData {
  String? uid;
  String? name;
  String? pubkey;
  String? pkey;
  String? email;
  String? mobile;
  String? secret;
  bool? registered;
  double? promowallet;
  double? paywallet;
  DateTime? lastupdate;

  UserData({
    this.uid,
    this.pubkey,
    this.pkey,
    this.email,
    this.name,
    this.mobile,
    this.registered,
    this.secret,
    this.promowallet,
    this.paywallet,
    this.lastupdate,
  });
}

class dbVal {
  bool? hasDB;
  dbVal({
    this.hasDB,
  });
}
