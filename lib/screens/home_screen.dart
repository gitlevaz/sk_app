import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:overlay_support/overlay_support.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    // Request permission (for iOS)
    FirebaseMessaging.instance.requestPermission();

    // Get the token
    FirebaseMessaging.instance.getToken().then((token) {
      print("FCM Token: $token");
    });

    // Foreground message listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        showSimpleNotification(
          Text(message.notification!.title ?? 'No title'),
          subtitle: Text(message.notification!.body ?? 'No body'),
          background: Colors.blue,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("Firebase In-App Notification Demo")),
    );
  }
}
