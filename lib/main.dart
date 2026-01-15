import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:sahakaru/providers/interest_provider.dart';
import 'package:sahakaru/providers/member_provider.dart';
import 'package:sahakaru/providers/message_provider.dart';
import 'package:sahakaru/providers/user_provider.dart';
import 'package:sahakaru/screens/home_screen.dart';
import 'package:sahakaru/screens/auth_pages/login_screen.dart';
import 'package:sahakaru/screens/member_pages/members_screen.dart';
import 'package:sahakaru/screens/Interests_pages/found_interests_screen.dart';
import 'package:sahakaru/screens/message_pages/message_list_screen.dart';
import 'package:sahakaru/screens/Interests_pages/request_interests_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sahakaru/screens/purchase/purchase_screen.dart';
import 'firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// ----------------------------------------------------------------------
/// Initialize Local Notifications
/// ---------------------------------------------------------------------

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// 📌 Background message handler (must be top-level)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  _showNotification(message); // show notification in background
}

/// 📌 Show system notification
Future<void> _showNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'high_importance_channel', // MUST match channel ID
    'High Importance Notifications',
    channelDescription: 'This channel is used for important notifications.',
    importance: Importance.max,
    priority: Priority.high,
  );

  const NotificationDetails platformDetails = NotificationDetails(
    android: androidDetails,
  );

  await flutterLocalNotificationsPlugin.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000, // unique id
    message.notification?.title ?? 'No Title',
    message.notification?.body ?? 'No Body',
    platformDetails,
  );
}

/// ----------------------------------------------------------------------
/// MAIN
/// ----------------------------------------------------------------------
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Required for background & terminated notifications
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Local notification settings
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Firebase messaging instance
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  /// 🔐 Request permission for notifications
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  print("Notification Permission: ${settings.authorizationStatus}");

  /// 🔑 Get FCM Token
  String? token = await messaging.getToken();
  print("🔥 FCM TOKEN: $token");

  /// 📩 Foreground notifications
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("📩 Foreground message received: ${message.notification?.title}");
    _showNotification(message); // show in notification bar
  });

  /// 🟢 User taps notification (app opened)
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print("🟢 Notification clicked: ${message.notification?.title}");
  });

  runApp(
    OverlaySupport.global(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (_) => MemberProvider()),
          ChangeNotifierProvider(create: (_) => InterestProvider()),
          ChangeNotifierProvider(create: (_) => MessageProvider()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

/// ----------------------------------------------------------------------
/// APP START
/// ----------------------------------------------------------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sahakaru',
      theme: ThemeData(primarySwatch: Colors.red),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/members': (context) => const MembersScreen(),
        '/main': (context) => const MainScreen(),
        '/purchase': (context) => const PurchaseScreen(),

      },
    );
  }
}

/// ----------------------------------------------------------------------
/// BOTTOM NAVIGATION
/// ----------------------------------------------------------------------
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 3; // default: Members page

  final List<Widget> _pages = const [
    RequestInterestsPage(),
    FoundInterestsScreen(),
    MessageListScreen(),
    MembersScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.pink,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Request',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            label: 'Found',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Members',
          ),
        ],
      ),
    );
  }
}
