import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'query/askquery.dart';
import 'query/reviewquery.dart';
import 'query/notificationlist.dart';
import 'package:flutter/services.dart';
import 'auth/registration.dart';
import 'auth/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/notificationsController.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print('Handling a background message ${message.data}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
    NotificationContoller notifyobj = NotificationContoller((test) {}, (test) {});

   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp],
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Padhai Vadhai',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        primaryColor:  Color(0xfff2a350),
        backgroundColor:  Color(0xffacddde),
      
      ),
      routes: {
        '/': (context) => HomePage(),
         'home': (context) => HomePage(),
        'askquery': (context) => AskQuery(),
        'listquery': (context) => ListQuery(),
        'registration': (context) => Registration(),
        'login': (context) => Login(),
        'notificationlist' :  (context) => NotificationList(),
      },
    );
  }
}
