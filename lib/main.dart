
import 'package:flutter/material.dart';
import 'package:telkom/ui/splashscreen/splash_screen.dart';
import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'firebase_options.dart';
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true
  );
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  });
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  String? _token;
  String? initialMessage;
  bool _resolved = false;

  void initState() {


    // FirebaseMessaging.onMessage.listen(showFlutterNotification);
    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    //   print('A new onMessageOpenedApp event was published!');
    //
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyBirawa Checklist ATM',
      theme: ThemeData(primarySwatch: Colors.red),
      darkTheme: ThemeData(primarySwatch: Colors.red),
      debugShowCheckedModeBanner: false,
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
      home: const SplashScreen(),
    );
  }
}
