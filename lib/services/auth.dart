import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:lockstars_app/models/user.dart';
import 'package:lockstars_app/screens/auth/otp.dart';
import 'package:lockstars_app/services/database.dart';
import 'package:lockstars_app/services/gpg.dart';
import 'package:lockstars_app/shared/globals.dart';
import 'package:openpgp/model/bridge_model_generated.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

/*
  UserL userFromFirebaseUser(User user) {
    return user != null ? UserL(uid: user.uid) : null;
  }

  // auth change user stream
  Stream<UserL> get user {
    //return _auth.onAuthStateChanged
    return _auth
        .authStateChanges()
        .map((User user) => _userFromFirebaseUser(user));
        //.map(_userFromFirebaseUser(UserL);
  }*/

  Stream<User?> get onAuthStateChanged => _auth.authStateChanges();

// get current uid
  Future<String> getCurrentUID() async {
    return _auth.currentUser!.uid;
  }

  late String lverificationCode;
  String mobile = '';
  int wallet = 0;

  // sign in with email and password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      //AuthResult result = await _auth.signInWithEmailAndPassword(
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      return user;
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  // sign in with mobile
  Future<String?> signInWithMobile(String mobile, String pin) async {
    String? useruid;
    var res;
    try {
      print("using pin = $pin against _verificationcode = $lverificationCode.");
      res = await _auth
          .signInWithCredential(PhoneAuthProvider.credential(
              verificationId: lverificationCode, smsCode: pin))
          .then((value) async {
        if (value.user != null) {
          useruid = value.user!.uid;
          print("user ${value.user} had signed in manually with uid $useruid.");
          /*
          DatabaseService _db = DatabaseService(uid: "dummy");
          var ret = await _db.accountCheckAndCreation(value.user!.uid, mobile);
          if (ret) {
            print("account check/creation successful");
          } else {
            print("account check/creation failed");
          }*/
          /*
          if (loadPref(encodeB64(value.user.uid)) == null) {
            //no preference data exists. new user? or transfer?
            print("no global data yet");
            //fetch data from firestore then saveToPref(encodeB64(user.uid));
          } else {}

          */
          //auth.userFromFirebaseUser(value.user);
          /*Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => Home()),
                          (route) => false);*/
        } else {
          print("userid is null!");
        }
      });
    } catch (e) {
      print('ERR: ${e.toString()}');
      //print('invalid OTP - auth');
      //useruid = "";
    }
    return useruid;
    /*try {
      //AuthResult result = await _auth.signInWithEmailAndPassword(
      await _auth.verifyPhoneNumber(
        phoneNumber: mobile,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // ANDROID ONLY!

          // Sign the user in (or link) with the auto-generated credential
          await _auth.signInWithCredential(credential);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
        verificationFailed: (FirebaseAuthException error) {
          if (error.code == 'invalid-phone-number') {
            print('The provided phone number is not valid.');
          }
        },
        codeSent: (String verificationId, int forceResendingToken) async {
          // Update the UI - wait for the user to enter the SMS code
          String smsCode = 'xxxx';

          // Create a PhoneAuthCredential with the code
          PhoneAuthCredential credential = PhoneAuthProvider.credential(
              verificationId: verificationId, smsCode: smsCode);

          // Sign the user in (or link) with the credential
          await _auth.signInWithCredential(credential);
        },
      );
      //User user = result.user;
      return mobile;
    } catch (error) {
      print(error.toString());
      return null;
    }*/
  }

  Future verifyPhone(String mobileNumber) async {
    print("verifying phone number $mobileNumber");
    await _auth.verifyPhoneNumber(
        phoneNumber: mobileNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance
              .signInWithCredential(credential)
              .then((value) async {
            if (value.user != null) {
              //valid user. Check if we already have a user registry for them.
              print("user ${value.user} had signed in automatically.");
              /*
              DatabaseService _db = DatabaseService(uid: "dummy");
              var ret =
                  await _db.accountCheckAndCreation(value.user!.uid, mobile);
              if (ret) {
                print("account check/creation successful -auto");
              } else {
                print("account check/creation failed -auto");
              }*/
              /*
              if (DatabaseService(uid: value.user.uid)
                      .getUserDocID(mobileNumber, value.user.uid, true) ==
                  null) {
                //no user doc, but this is a valid user. Register in database

              }
              if (loadPref(encodeB64(value.user.uid)) == null) {
                //no preference data exists. new user? or transfer?
                print("no global data yet");
                //fetch data from firestore then saveToPref(encodeB64(user.uid));
              } else {}
              */

              //return _userFromFirebaseUser(value.user);
              /*Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Home()),
                  (route) => false);*/
            }
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          print(e.message);
          return null;
        },
        codeSent: (String? verficationID, int? resendToken) {
          lverificationCode = verficationID!;
          print("verification code arrived 1: $lverificationCode");
        },
        codeAutoRetrievalTimeout: (String verificationID) {
          //setState(() {
          lverificationCode = verificationID;
          print("verification code arrived 2: $lverificationCode");
          //});
        },
        timeout: Duration(seconds: 30));
  }

  // sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

}
