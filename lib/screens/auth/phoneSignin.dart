import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:lockstars_app/screens/auth/otp.dart';
import 'package:lockstars_app/screens/auth/phSignIn.dart';
//import 'package:locky_app/services/auth.dart';
//import 'package:locky_app/services/gpg.dart';
//import 'package:locky_app/services/otp.dart';
//import 'package:locky_app/shared/constants.dart';
//import 'package:locky_app/shared/globals.dart';
import 'package:lockstars_app/screens/loading.dart';
import 'package:lockstars_app/services/gpg.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_phone_auth_handler/firebase_phone_auth_handler.dart';
import 'package:lockstars_app/shared/globals.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  //final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String error = '';
  bool loading = false;
  bool signinEn = false;

  // text field state
  String email = '';
  String mobile = '';
  String password = '';

  final TextEditingController controller = TextEditingController();
  String initialCountry = 'PH';
  PhoneNumber mnumber = PhoneNumber(isoCode: 'PH');
  bool numberReady = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            backgroundColor: Colors.blue[100],
            appBar: AppBar(
              backgroundColor: Colors.blue[400],
              elevation: 0.0,
              title: Text('Sign in to Lockstars'),
              actions: <Widget>[
                /*TextButton.icon(
                  icon: Icon(Icons.person),
                  style: TextButton.styleFrom(primary: Colors.white),
                  label: Text('Register'),
                  onPressed: () => widget.toggleView(),
                ),*/
              ],
            ),
            body: Container(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    InternationalPhoneNumberInput(
                      countries: ['PH'],
                      hintText: "Phone Number",
                      errorMessage: "Invalid Phone Number",
                      autoFocus: true,
                      onSubmit: () {
                        if (numberReady) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => OTPScreen(mobile)));
                        } else {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) =>
                                  CupertinoAlertDialog(
                                    title: Text('Phone Number Invalid'),
                                    content: Text(
                                        'You have entered an invalid number. '
                                        'Kindly check the number and try again.'),
                                    actions: <Widget>[
                                      CupertinoDialogAction(
                                        child: Text('OK'),
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                      )
                                    ],
                                  ));
                        }
                      },
                      onInputChanged: (PhoneNumber number) {
                        int phoneNumber = number.phoneNumber!.length;
                        if (number.phoneNumber!.length == 13) {
                          numberReady = true;
                        }
                        mnumber = number;
                      },
                      onInputValidated: (bool value) {
                        print(value);
                        if (signinEn != value) {
                          signinEn = value;
                          setState(() {});
                        }
                        // numberReady = value;
                        if (numberReady) {
                          mobile = mnumber.phoneNumber!;
                          email = '${encodeB64(mobile)}@user.locky.app';
                          //email = '${encodeB64(mobile)}@user.locky.app';
                          print("mobile number = $mobile and email = $email");
                        }
                      },
                      selectorConfig: SelectorConfig(
                        selectorType:
                            PhoneInputSelectorType.DROPDOWN, // BOTTOM_SHEET,
                      ),
                      ignoreBlank: false,
                      autoValidateMode: AutovalidateMode.disabled,
                      selectorTextStyle: TextStyle(color: Colors.black),
                      initialValue: mnumber,
                      textFieldController: controller,
                      formatInput: false,
                      inputDecoration: InputDecoration(
                        hintText: "Enter Mobile Number",
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                          signed: true, decimal: true),
                      onSaved: (PhoneNumber number) {
                        print('On Saved: $number');
                      },
                    ),
                    /*SizedBox(height: 20.0),
                    TextFormField(
                      decoration: textInputDecoration.copyWith(
                          hintText: 'Mobile Number'),
                      validator: (val) =>
                          val.isEmpty ? 'Enter your Mobile Number' : null,
                      onChanged: (val) {
                        setState(() => email = val + '@lockstar.co');
                        setState(() => mobile = val);
                      },
                    ),*/
                    SizedBox(height: 20.0),
                    ElevatedButton(
                        //color: Colors.pink[400],
                        child: Text(
                          'Sign In',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () async {
                          /* Web version only
                              onPressed: !(signinEn)
                                  ? null
                                  : () {
                              print('mobile -> $mobile');
                              print('numberReady -> $numberReady');
                          */
                          if (numberReady) {
                            GlobalData.whoami.mobile = mobile;
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => OTPScreen(mobile)));
                            // Navigator.of(context).push(MaterialPageRoute(builder: (context) => nSignIn(mobile)));
                          } else {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    CupertinoAlertDialog(
                                      title: Text('Phone Number Invalid'),
                                      content: Text(
                                          'You have entered an invalid number. '
                                          'Kindly check the number and try again.'),
                                      actions: <Widget>[
                                        CupertinoDialogAction(
                                          child: Text('OK'),
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                        )
                                      ],
                                    ));
                          }
                          /*
                          if (_formKey.currentState.validate()) {
                            setState(() => loading = true);
                            dynamic result = await _auth
                                .signInWithEmailAndPassword(email, password);
                            if (result == null) {
                              setState(() {
                                loading = false;
                                error =
                                    'Could not sign in with those credentials';
                              });
                            } else {
                              if (loadPref(encodeB64(result.uid)) == null) {
                                //no preference data exists. new user? or transfer?
                                print("no global data yet");
                                //fetch data from firestore then saveToPref(encodeB64(user.uid));
                              } else {
                                print(
                                    "global data available for ${GlobalData.email}.");
                              }
                            }
                          }*/
                        }),
                    SizedBox(height: 12.0),
                    Text(
                      error,
                      style: TextStyle(color: Colors.red, fontSize: 14.0),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
