import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:kano/constants.dart';

import '../service/kano_http.dart';

class PaymentController extends GetxController {
  final cashSelected = true.obs;
  final isLoading = false.obs;
  final isLoadingPM = false.obs;
  final selectedIndex = 0.obs;
  final userData = {}.obs;
  final paymentMethods = [].obs;
  final user = FirebaseAuth.instance.currentUser;

  _fetchPaymentMethods() async {
    isLoadingPM(true);
    FirebaseFirestore.instance
        .doc("users/${user!.uid}")
        .snapshots()
        .listen((DocumentSnapshot docs) {
      final doc = docs.data() as Map<String, dynamic>;
      if (doc["paymentMethods"] != null) {
        paymentMethods.value = doc["paymentMethods"];
      }
      isLoadingPM(false);
    });
  }

  Future<void> saveCard() async {
    try {
      isLoading(true);

      //create a customer first

      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );

      final data = {
        "id": paymentMethod.id,
        "brand": paymentMethod.card.brand,
        "cardCountry": paymentMethod.card.country,
        "expYear": paymentMethod.card.expYear,
        "expMonth": paymentMethod.card.expMonth,
        "funding": paymentMethod.card.funding,
        "last4": paymentMethod.card.last4,
        "billingCountry": paymentMethod.billingDetails.address?.country,
      };

      //save card to API

      http.Response response = await http.post(
        Uri.parse("$apiBaseUrl/api/payment/${user!.uid}/savecard"),
        //headers: {'Content-Type': "application/json"},
        body: jsonEncode(data),
      );
      isLoading(false);

      if (response.statusCode == 200) {
        // Request successful
        Get.back();
      } else {
        // Request failed
        Fluttertoast.showToast(
          msg: "Veuillez remplir tous les champs de la carte",
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      isLoading(false);
      Fluttertoast.showToast(
        msg: "Veuillez remplir tous les champs de la carte",
        backgroundColor: Colors.red,
      );
    }
  }

  _add(dynamic paymentMethod) async {
    await FirebaseFirestore.instance
        .doc("users/${user!.uid}")
        .set({'paymentMethods': paymentMethod}, SetOptions(merge: true));
  }

  Future<dynamic> pay({required String orderId}) {
    isLoading(true);
    final cardId = paymentMethods[selectedIndex.value]["id"];
    return http_post("/api/payment/retry/$orderId/$cardId", {});
  }

  @override
  void onInit() {
    super.onInit();
    _fetchPaymentMethods();
  }
}
