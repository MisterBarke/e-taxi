import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AppController extends GetxController {
  final currentLocal = "fr".obs;
  final user = FirebaseAuth.instance.currentUser;
  final address = [].obs;

  getUserAddress() {
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .snapshots()
        .listen((event) {
      final data = event.data() as Map<String, dynamic>;
      address.value = [];
      address.addAll([
        {
          "name": "Maison",
          "icon": const Icon(Icons.home),
          "location": data["homeLocation"],
        },
        {
          "name": "Travail",
          "icon": const Icon(Icons.work_outline),
          "location": data["workLocation"],
        },
        {
          "name": "Gym",
          "icon": const Icon(Icons.sports_martial_arts),
          "location": data["gymLocation"],
        }
      ]);
    });
  }
}
