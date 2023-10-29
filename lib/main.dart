import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kano/business/controller/auth_controller.dart';
import 'package:kano/constants.dart';
import 'package:kano/splashscreen.dart';
import 'package:kano/translation/messages.dart';
import 'package:kano/ui/onboarding.dart';
import 'package:kano/ui/screens/home.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:kano/ui/screens/notifications/notifications.dart';
import 'business/service/firebase_messaging_api.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage? message) async {
  if (message != null) {
    Get.to(() => Notifications());
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //INITIALIZE FIREBASE
  await Firebase.initializeApp();
  //INITIALIZE GETSTORAGE
  await GetStorage.init();
  // set the publishable key for Stripe - this is mandatory
  Stripe.publishableKey = stripePublishableKey;
  // subscribe to topic on each app start-up
  FirebaseMessaging.instance.subscribeToTopic('KANO');
  //FIREBASE BACKGROUND MESSAGE
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  //firebase message init function
  await FirebaseMessagingApi().initNotifications();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Future<FirebaseApp> _initFirebaseSdk = Firebase.initializeApp();
  AuthController? authController;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.white, // navigation bar color
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark // status bar color
          ),
    );
    return GetMaterialApp(
      title: 'KANO VTC',
      locale: const Locale('fr'),
      fallbackLocale: const Locale('en'),
      translations: Messages(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }

  @override
  void initState() {
    _initFirebaseSdk.then((value) async {
      log("Firebase initialized !");
      authController = Get.put(AuthController());
      setState(() {});
    });

    super.initState();
  }
}
