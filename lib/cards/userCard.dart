import 'package:flutter/material.dart';
import 'package:lockstars_app/models/user.dart';
import 'package:provider/provider.dart';

class USERCARD extends StatefulWidget {
  @override
  _UserState createState() => _UserState();
}

class _UserState extends State<USERCARD> {
  @override
  Widget build(BuildContext context) {
    final uuser = Provider.of<UserData>(context);
    //final uuser = Provider.of<UserL>(context) ?? null;
    // ignore: unnecessary_null_comparison
    if (uuser != null) {
      return Card(
        child: ListTile(
          onTap: () async {
            //Navigator.pushAndRemoveUntil(context, ModalRoute.withName('/wallet'), (route) => false);
            Navigator.pushNamed(context, "/wallet");
          },
          leading: Icon(Icons.person),
          title: Text(
              "TEST HERE USERCARD -> ${(uuser.registered ?? false) ? uuser.name : uuser.mobile}"),
          subtitle: Text(
              "Wallet: ${uuser.paywallet?.toStringAsFixed(2)} + ${uuser.promowallet?.toStringAsFixed(2)}P stars\nMobile: ${uuser.mobile ?? 'NaN'}"),
          //tileColor: ((uuser.paywallet ?? 0) < 10) ? Colors.red : Colors.white,
          contentPadding: EdgeInsets.fromLTRB(8, 20, 0, 0),
        ),
      );
    } else {
      return Card(
        child: ListTile(
          leading: Icon(Icons.wallet_giftcard),
          title: Text('Loading user information'),
          subtitle: Text("Wallet: ?? \nMobile: ??"),
        ),
      );
    }
  }
}

class BLANKCARD extends StatefulWidget {
  @override
  _BlankState createState() => _BlankState();
}

class _BlankState extends State<USERCARD> {
  @override
  Widget build(BuildContext context) {
    //final uuser = Provider.of<UserData>(context) ?? null;
    return Card(
      child: ListTile(
        leading: Icon(Icons.wallet_giftcard),
        title: Text('Loading user information'),
        subtitle: Text("Wallet: ?? \nMobile: ??"),
      ),
    );
  }
}
