import 'dart:convert';
import 'package:openpgp/openpgp.dart';
import 'package:fast_rsa/rsa.dart';

Codec<String, String> stringToBase64 = utf8.fuse(base64);

Future<KeyPair?> generateKeyPair(String name, String email, String uuid) async {
  var ret;
  try {
    print("openpgp args $name $email $uuid");
    String? passk = await encodeB64(uuid);
    dynamic keyOptions = KeyOptions()..rsaBits = 1024;
    KeyPair? kp = await OpenPGP.generate(
        options: Options()
          ..name = name
          ..email = email
          ..passphrase = passk
          ..keyOptions = keyOptions);
    /*
    GlobalData.user = name;
    GlobalData.email = email;
    GlobalData.secret = passk;
    GlobalData.pKey = kp.privateKey;
    GlobalData.pubKey = kp.publicKey;
    GlobalData.mobile = name;
    GlobalData.wallet = 0;
    await DatabaseService(uid: uuid).updateUserData(
        GlobalData.pubKey,
        GlobalData.pKey,
        GlobalData.mobile,
        GlobalData.email,
        GlobalData.mobile,
        0);
    saveToPref(passk);
    print(
        "global data available for ${GlobalData.email},${GlobalData.mobile}.");
        */
    print("public key is ${kp.publicKey}");
    ret = kp;
  } catch (error) {
    print("openpgpg err ${error.toString()}");
  }
  return ret;
}

Future encryptData(String strData, String pubKey) async {
  String b64enc = "";
  try {
    b64enc = await OpenPGP.encrypt(strData, pubKey);
    b64enc = (await encodeB64(b64enc))!;
    //stringToBase64.encode(b64enc);
  } catch (error) {
    print(error.toString());
    return null;
  }
  return b64enc;
}

Future decryptData(String strData, String pKey, String secret) async {
  String b64dec = "";
  try {
    b64dec = (await decodeB64(strData))!;
    b64dec = await OpenPGP.decrypt(b64dec, pKey, secret);
  } catch (error) {
    print(error.toString());
    return null;
  }
  return b64dec;
}

Future<String?> encodeB64(String str) async {
  String ret = "";
  try {
    ret = stringToBase64.encode(str);
  } catch (e) {
    return null;
  }
  return ret;
}

Future<String?> decodeB64(String str) async {
  String ret = "";
  try {
    ret = stringToBase64.decode(str);
  } catch (e) {
    return null;
  }
  return ret;
}
