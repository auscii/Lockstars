import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lockstars_app/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalData {
  static UserData whoami = UserData(
      uid: null,
      name: null,
      pubkey: null,
      pkey: null,
      email: null,
      mobile: null,
      secret: null,
      promowallet: 0,
      paywallet: 0);
  static String domainx = "pub.locky.co";
  //static Colors mainColor = Colors.blue as Colors;
}

class transactionData {
  static String selLocker = "";
  static String selUnlocker = "";
  static String selPayer = "";
  static String selInitiator = "";
  static String selUnlockCode = "";
  static String seldecUnlockCode = "";
  static double selRate = 10;
  static Timestamp selStartTime = Timestamp.now();
  static int selChargeHour = 0;
  static bool loading = false;
  static String? payLink = "";
}

void saveHash(int suff) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt('messHash', suff);
}

Future<int?> loadHash() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt("messHash") ?? null;
}
/*
void saveToPref(String suff) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('${suff}_lockyemail', GlobalData.email);
  prefs.setString('${suff}_lockypkey', GlobalData.pKey);
  prefs.setString('${suff}_lockypubkey', GlobalData.pubKey);
  prefs.setString('${suff}_lockysecret', GlobalData.secret);
  prefs.setString('${suff}_lockyuser', GlobalData.user);
  prefs.setString('${suff}_lockymobile', GlobalData.mobile);
  prefs.setString('${suff}_lockyuid', GlobalData.uuid);
  prefs.setInt('${suff}_lockywallet', GlobalData.wallet);
}

Future<String> loadPref(String suff) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  GlobalData.email = prefs.getString('${suff}_lockyemail') ?? null;
  GlobalData.pKey = prefs.getString('${suff}_lockypkey') ?? null;
  GlobalData.pubKey = prefs.getString('${suff}_lockypubkey') ?? null;
  GlobalData.secret = prefs.getString('${suff}_lockysecret') ?? null;
  GlobalData.user = prefs.getString('${suff}_lockyuser') ?? null;
  GlobalData.mobile = (prefs.getString('${suff}_lockymobile') ?? null) == ''
      ? null
      : prefs.getString('${suff}_lockymobile');
  GlobalData.uuid = prefs.getString('${suff}_lockyuid') ?? null;
  GlobalData.wallet = prefs.getInt('${suff}_lockywallet') ?? 0;
  return GlobalData.email ?? null;
}
*/