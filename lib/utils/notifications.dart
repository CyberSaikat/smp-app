// import 'dart:io';
//
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:student_management/root/classes.dart';
// import 'package:student_management/root/internal_marks.dart';
// import 'package:student_management/utils/utils.dart';
//
// class NotificationServices {
//   // Initialize FirebaseMessaging and FlutterLocalNotificationsPlugin instances
//   FirebaseMessaging messaging = FirebaseMessaging.instance;
//   final FlutterLocalNotificationsPlugin notificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//
//   // Get the device token for FCM
//   Future<String?> getDeviceToken() async {
//     return await messaging.getToken();
//   }
//
//   // Listen for token refresh events
//   void isRefreshed() async {
//     messaging.onTokenRefresh.listen((event) {
//       event.toString();
//     });
//   }
//
//   // Request notification permissions from the user
//   void requestPermission() async {
//     await FirebaseMessaging.instance.requestPermission(
//       alert: true,
//       announcement: false,
//       badge: true,
//       carPlay: false,
//       criticalAlert: false,
//       provisional: false,
//       sound: true,
//     );
//   }
//
//   // Set foreground notification presentation options
//   Future foregroundNotification() async {
//     await messaging.setForegroundNotificationPresentationOptions(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//   }
//
//   // Initialize local notifications and handle incoming messages
//   void firebaseInit(BuildContext context) {
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       if (Platform.isAndroid) {
//         initLocalNotification(context, message);
//         displayNotification(message);
//       }
//     });
//   }
//
//   // Initialize local notifications for Android
//   void initLocalNotification(
//       BuildContext context, RemoteMessage message) async {
//     AndroidInitializationSettings initializationSettingsAndroid =
//         const AndroidInitializationSettings('@mipmap/ic_launcher');
//     var initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: const DarwinInitializationSettings(),
//     );
//     await notificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: (payload) {
//         handleMessage(context, message);
//       },
//     );
//   }
//
//   // Handle incoming messages and navigate to the appropriate screen
//   void handleMessage(BuildContext context, RemoteMessage message) {
//     if (message.data['type'] == 'class') {
//       Navigator.push(
//         context,
//         CupertinoPageRoute(
//           builder: (context) => const Classes(),
//         ),
//       );
//     } else if (message.data['type'] == 'internal') {
//       Navigator.push(
//         context,
//         CupertinoPageRoute(
//           builder: (context) => const InternalMarks(),
//         ),
//       );
//     } else if (message.data['type'] == 'notification') {
//       Navigator.push(
//         context,
//         CupertinoPageRoute(
//           builder: (context) => const CheckUser(),
//         ),
//       );
//     }
//   }
//
//   // Display a local notification
//   void displayNotification(RemoteMessage message) async {
//     AndroidNotification? android = message.notification?.android;
//     AndroidNotificationChannel channel = const AndroidNotificationChannel(
//       'high_importance_channel',
//       'High Importance Notifications',
//       importance: Importance.high,
//       playSound: true,
//       showBadge: true,
//     );
//
//     AndroidNotificationDetails notificationDetails = AndroidNotificationDetails(
//       channel.id,
//       channel.name,
//       channelDescription: channel.description,
//       importance: Importance.high,
//       priority: Priority.high,
//       playSound: true,
//       icon: android?.smallIcon,
//       enableLights: true,
//       enableVibration: true,
//       color: const Color.fromARGB(255, 255, 0, 0),
//     );
//
//     NotificationDetails notificationDetailsAndroid = NotificationDetails(
//       android: notificationDetails,
//     );
//
//     Future.delayed(Duration.zero, () {
//       notificationsPlugin.show(
//         0,
//         message.notification?.title,
//         message.notification?.body,
//         notificationDetailsAndroid,
//         payload: message.data['type'],
//       );
//     });
//   }
// }
