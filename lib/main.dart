// ----// @dart=2.9
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lockstars_app/screens/auth/auth_provider.dart';
import 'package:lockstars_app/screens/auth/phoneSignin.dart';
import 'package:lockstars_app/screens/home/userHome.dart';
import 'package:lockstars_app/screens/loading.dart';
import 'package:lockstars_app/services/auth.dart';
import 'package:lockstars_app/shared/globals.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    importance: Importance.high,
    playSound: true);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Test FCM message -> ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //User? user = FirebaseAuth.instance.currentUser;
  //only add these if you're on the latest firebase
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  runApp(MyApp());
  FirebaseMessaging.instance.getToken().then(print);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // final uuser = Provider.of<UserData>(context);
    return authProvider(
      auth: AuthService(),
      child: MaterialApp(
        title: 'Lockstars',
        theme: ThemeData(
          // fontFamily: "Montserrat",
          brightness: Brightness.light,
          inputDecorationTheme: InputDecorationTheme(
            contentPadding:
                EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
          primarySwatch: Colors.grey, //Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomeController(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class HomeController extends StatefulWidget {
  //StatelessWidget {
  HomeController({Key? key}) : super(key: key);
  // const HomeController({Key? key}) : super(key: key);

  @override
  _HomeController createState() => _HomeController();

  //2
  @override
  Widget build(BuildContext context) {
    return authProvider(
      auth: AuthService(),
      child: MaterialApp(
        title: 'Lockstars',
        theme: ThemeData(
          // fontFamily: "Montserrat",
          brightness: Brightness.light,
          inputDecorationTheme: InputDecorationTheme(
            contentPadding:
                EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
          primarySwatch: Colors.grey, //Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class _HomeController extends State<HomeController> {
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    // Future.delayed(Duration.zero, () {
    //     this.welcomeUser();
    // });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      late final FirebaseMessaging _messaging;
      if (notification != null && android != null) {
        // Android
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                //channel.description,
                color: Colors.blue,
                playSound: true,
                icon: '@mipmap/ic_launcher',
              ),
            ));
      }
      if (kIsWeb) {
        // Web - getting FCM notification
        final title = message.notification?.title,
            body = message.notification?.body;
        showDialog(
            context: context,
            builder: (context) {
              return SimpleDialog(
                  contentPadding: EdgeInsets.all(18),
                  children: [
                    Text('Title: $title'),
                    Text('Body: $body'),
                  ]);
            });
      }
      //iOS FCM
      await Firebase.initializeApp();
      _messaging = FirebaseMessaging.instance;
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission');
        // TODO: handle the received notifications
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          // Parse the message received
          var title = message.notification?.title,
              body = message.notification?.body;
          PushNotification notification = PushNotification(
            title: message.notification?.title,
            body: message.notification?.body,
          );
          // print('pushNotification -> $notification \n');
          // print('messageNotification title -> $title');
          // print('messageNotification body -> $body');
        });
      } else {
        print('User declined or has not accepted permission');
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(notification.title ?? ""),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(notification.body ?? "")],
                  ),
                ),
              );
            }
        );
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    // Future.delayed(Duration.zero, () => showAlert(context));
    final AuthService auth = authProvider.of(context)!.auth;
    //DatabaseService _db = DatabaseService(uid: "dummy");
    return StreamBuilder<User?>(
        stream: auth.onAuthStateChanged,
        //builder: (context, AsyncSnapshot<String> snapshot) {
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final bool signedIn = snapshot.hasData;
            final user = snapshot.data;
            if (signedIn) {
              // ignore: unnecessary_null_comparison
              if (user == null) {
                return Loading();
              } else {
                GlobalData.whoami.name = "";
                GlobalData.whoami.uid = user.uid;
                GlobalData.whoami.mobile = user.phoneNumber;
                GlobalData.whoami.email = "";
                
                print('GLOBAL DATA REGISTERED VALUE ->$GlobalData.whoami.registered');

                //return dbPopulate();
                return userHome(
                  uid: user.uid,
                );
              }
            } else {
              return SignIn();
              //return nSignIn();
            }
          } else {
            return Container(
              color: Colors.black,
            );
          }
        });
  }

}

class PushNotification {
  PushNotification({
    this.title,
    this.body,
  });
  String? title;
  String? body;
}
