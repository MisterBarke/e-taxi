import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../ui/onboarding.dart';
import '../../ui/screens/home.dart';

class SplashScreenController extends GetxController {
  final box = GetStorage();
  late int use;

  @override
  void onInit() {
    super.onInit();
    listenAuthChanges();
    Future.delayed(const Duration(seconds: 2), () async {
      use == 0
          ? Get.off(() => const Onboarding())
          : Get.off(() => const AppHome());
    });
  }

  listenAuthChanges() async {
    final box = GetStorage();
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user == null) {
        use = 0;
        print('User is currently signed out sp!');
        box.write("user", null);
      } else {
        final currentUser = FirebaseAuth.instance.currentUser;
        use = 1;
        print('User is signed in sp!');
        final userData = box.read("user");
        if (userData == null) {
          var result = await FirebaseFirestore.instance
              .collection("users")
              .where("phone", isEqualTo: currentUser!.phoneNumber)
              .get();
          final data = result.docs.first.data();
          await box.write("user", data);
        }
      }
    });
  }
}
