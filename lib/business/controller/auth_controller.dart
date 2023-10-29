import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';

class AuthController extends GetxController {
  final authData = {"user": null}.obs;
  final isAuthenticated = false.obs;

  // Firebase ressources
  late final FirebaseAuth _auth;
  late final FirebaseFirestore _firestore;
  final box = GetStorage();

  final tokenID = "".obs;

  final payments = <Map<String, dynamic>>[].obs;

  AuthController() {
    _auth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;
    _getToken();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> findUser(String phoneNumber) {
    return _firestore
        .collection("users")
        .where("phone", isEqualTo: phoneNumber)
        .limit(1)
        .get();
  }

  verifyPhoneNumber(String phoneNumber,
      {required Function codeSent,
      required Function verificationCompleted,
      required Function verificationFailed,
      required Function codeAutoRetrievalTimeout}) {
    log("Verifiying phone : $phoneNumber");

    _auth.verifyPhoneNumber(
      timeout: const Duration(seconds: 30),
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {
        verificationCompleted(credential);
      },
      verificationFailed: (FirebaseAuthException exception) {
        verificationFailed(exception);
      },
      codeSent: (code, resendToken) {
        codeSent(code, resendToken);
      },
      codeAutoRetrievalTimeout: (data) {
        print(data);
        codeAutoRetrievalTimeout(data);
      },
    );
  }

  Future<void> registerUser(dynamic userData) async {
    return await _firestore
        .collection("users")
        .doc(userData["uid"])
        .set(userData);
  }

  Future<void> updateUserTokenId(String uid, dynamic data) async {
    return await _firestore.collection("users").doc(uid).update(data);
  }

  Future<UserCredential?> signInWithOtp(
      String smsCode, String verificationId) async {
    try {
      final AuthCredential authCredential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: smsCode);

      return FirebaseAuth.instance.signInWithCredential(authCredential);
    } on Exception catch (_) {
      return Future(() => null);
    }
  }

  void saveUserInfos(dynamic user) {
    box.write("user", user);
  }

  dynamic getUser() {
    final user = box.read("user");
    return user;
  }

  void _getToken() async {
    tokenID.value = (await FirebaseMessaging.instance.getToken())!;
  }

  void fetchMyPaymentMethods() {
    if (_auth.currentUser != null) {
      log("Listening to current user payment methods");
      _firestore
          .collection("users")
          .doc(_auth.currentUser?.uid)
          .snapshots()
          .listen((event) {});
    }
  }
}
