import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lockstars_app/models/user.dart';
import 'package:lockstars_app/services/auth.dart';
import 'package:lockstars_app/services/database.dart';
import 'package:lockstars_app/shared/globals.dart';
//import 'package:locky_app/model/user.dart';
//import 'package:locky_app/screens/home/home.dart';
//import 'package:locky_app/services/auth.dart';
//import 'package:locky_app/services/database.dart';
//import 'package:locky_app/shared/globals.dart';
//import 'package:phone_auth_project/home.dart';
import 'package:pinput/pin_put/pin_put.dart';
//import 'gpg.dart';

class OTPScreen extends StatefulWidget {
  final String phone;
  OTPScreen(this.phone);
  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final AuthService auth = AuthService();
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();

  //late String _verificationCode;
  late String mobileNumber;
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();
  final BoxDecoration pinPutDecoration = BoxDecoration(
    color: const Color.fromRGBO(43, 46, 66, 1),
    borderRadius: BorderRadius.circular(10.0),
    border: Border.all(
      color: const Color.fromRGBO(126, 203, 224, 1),
    ),
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldkey,
      appBar: AppBar(
        title: Text('OTP Verification'),
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 40),
            child: Center(
              child: Text(
                '${widget.phone}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: PinPut(
              fieldsCount: 6,
              textStyle: const TextStyle(
                fontSize: 25.0,
                color: Colors.white,
                //backgroundColor: Colors.black,
              ),
              eachFieldWidth: 40.0,
              eachFieldHeight: 55.0,
              focusNode: _pinPutFocusNode,
              controller: _pinPutController,
              submittedFieldDecoration: pinPutDecoration,
              selectedFieldDecoration: pinPutDecoration,
              followingFieldDecoration: pinPutDecoration,
              pinAnimationType: PinAnimationType.fade,
              onSubmit: (pin) async {
                // _webSignInPhoneNumber();
                print("signing in ${widget.phone} with pin $pin");
                var useruid =
                    await auth.signInWithMobile('${widget.phone}', pin);
                print("useruid = $useruid");
                print("auth_signInWithMobile = $widget.phone");
                Navigator.pop(context);
                if (useruid == "") {
                  print("login failed.");
                  showDialog(
                      context: context,
                      builder: (BuildContext context) => CupertinoAlertDialog(
                            title: Text('Sign-in Error'),
                            content: Text(
                                'An error occured while trying to sign in. '
                                'Your OTP may be incorrect. Kindly try again later.'),
                            actions: <Widget>[
                              CupertinoDialogAction(
                                child: Text('OK'),
                                onPressed: () => Navigator.of(context).pop(),
                              )
                            ],
                          ));
                } else {
                  print("existing customer.");
                  //DatabaseService _db = DatabaseService(uid: useruid);
                  //UserData? uuser = await _db.getUserInfo(useruid);
                  //print("current user data: ${uuser.toString()}");
                }
                //Navigator.pop(context);
              },
              /*{
                try {
                  print(
                      "using pin = $pin against _verificationcode = $_verificationCode.");
                  await FirebaseAuth.instance
                      .signInWithCredential(PhoneAuthProvider.credential(
                          verificationId: _verificationCode, smsCode: pin))
                      .then((value) async {
                    if (value.user != null) {
                      print("user ${value.user} had signed in manually.");
                      if (await DatabaseService(uid: value.user.uid)
                              .getUserDocID(
                                  mobileNumber, value.user.uid, true) ==
                          //.checkUserID(value.user.uid) ==
                          null) {}
                      if (loadPref(encodeB64(value.user.uid)) == null) {
                        //no preference data exists. new user? or transfer?
                        print("no global data yet");
                        //fetch data from firestore then saveToPref(encodeB64(user.uid));
                      } else {}
                      //auth.userFromFirebaseUser(value.user);
                      Navigator.pop(context);
                      /*Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => Home()),
                          (route) => false);*/
                    }
                  });
                } catch (e) {
                  FocusScope.of(context).unfocus();
                  print('invalid OTP');
                }
              },*/
            ),
          )
        ],
      ),
    );
  }

  _webSignInPhoneNumber() async {
    print("widget.phone -> $widget.phone");
    await FirebaseAuth.instance.signInWithPhoneNumber(
        '${widget.phone}',
        RecaptchaVerifier(
          onSuccess: () => print('signInWithPhoneNumber reCAPTCHA Completed!'),
          onError: (FirebaseAuthException error) => print(error),
          onExpired: () => print('signInWithPhoneNumber reCAPTCHA Expired!'),
        )
        // RecaptchaVerifier(
        //   container: 'recaptcha',
        //   size: RecaptchaVerifierSize.compact,
        //   theme: RecaptchaVerifierTheme.dark,
        // )
        );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //_webSignInPhoneNumber();
    auth.verifyPhone('${widget.phone}');
  }
}
